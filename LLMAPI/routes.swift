import Foundation
import Vapor

// MARK: - Cache

struct CacheEntry {
    let ingredients: Set<String>
    let response: String
}

var responseCache: [CacheEntry] = []

func normalizeIngredients(_ text: String) -> Set<String> {
    Set(
        text.lowercased()
            .components(separatedBy: CharacterSet(charactersIn: ",\n;"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    )
}

func jaccardSimilarity(_ a: Set<String>, _ b: Set<String>) -> Double {
    let intersection = a.intersection(b).count
    let union = a.union(b).count
    return union == 0 ? 0 : Double(intersection) / Double(union)
}

func findCachedResponse(for ingredients: Set<String>) -> String? {
    let threshold = ingredients.count < 10 ? 0.75 : 0.85
    return responseCache.first { jaccardSimilarity($0.ingredients, ingredients) >= threshold }?.response
}

// MARK: - BotHub request

struct BotHubRequest: Content {
    let model: String
    let input: String
    let max_output_tokens: Int
}

// Функция для отправки запроса и ответа
func analyzeText(text: String, app: Application) -> EventLoopFuture<String> {
    let apiKey = Environment.get("BOTHUB_API_KEY") ?? "api-key"
    let model = Environment.get("LLM_MODEL") ?? "gemini-2.5-flash"
    let maxTokens = Int(Environment.get("MAX_TOKENS") ?? "1500") ?? 1500
    let url = "https://bothub.chat/api/v2/openai/v1/responses"

    var headers = HTTPHeaders()
    headers.add(name: .authorization, value: "Bearer \(apiKey)")
    headers.add(name: .contentType, value: "application/json")

    let body = BotHubRequest(model: model, input: text, max_output_tokens: maxTokens)
    
    let client = app.client
    return client.post(URI(string: url), headers: headers, content: body)
        .flatMapThrowing { response in
            guard response.status == .ok else {
                let errorBody = String(buffer: response.body ?? ByteBuffer())
                app.logger.error(" API failed: \(errorBody)")
                throw Abort(.internalServerError, reason: "Error calling  API")
            }
            
            let rawResponse = String(buffer: response.body ?? ByteBuffer())
            app.logger.info("Raw Response body: \(rawResponse)")
            return rawResponse
        }
}

// Эндпоинт
func routes(_ app: Application) throws {
    app.get("testt") { req -> String in
        return "Ok"
    }
    
    app.post("analyze") { req -> EventLoopFuture<AnalyzeResponse> in
        app.logger.info("Received request: \(req.body)")

        do {
            let analyzeRequest = try req.content.decode(AnalyzeRequest.self)
            app.logger.info("Decoded request: \(analyzeRequest)")

            let ingredients = normalizeIngredients(analyzeRequest.text)

            if let cached = findCachedResponse(for: ingredients) {
                app.logger.info("Cache hit for \(ingredients.count) ingredients")
                return req.eventLoop.makeSucceededFuture(AnalyzeResponse(output_text: cached))
            }

            let promptText = createPrompt(for: analyzeRequest.text)

            return analyzeText(text: promptText, app: app)
                .map { raw in
                    let outputText: String
                    if let data = raw.data(using: .utf8),
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let text = json["output_text"] as? String {
                        outputText = text
                    } else {
                        outputText = raw
                    }
                    responseCache.append(CacheEntry(ingredients: ingredients, response: outputText))
                    app.logger.info("Cache stored. Total entries: \(responseCache.count)")
                    return AnalyzeResponse(output_text: outputText)
                }
        } catch {
            app.logger.error("Error decoding request: \(error)")
            throw Abort(.badRequest, reason: "Invalid request format")
        }
    }
}

struct AnalyzeRequest: Content {
    let text: String
}

struct AnalyzeResponse: Content {
    let output_text: String
}

func createPrompt(for text: String) -> String {
    let prompt = """
    The AI should act as an expert in cosmetic ingredients, their impact on skin and human health. It should assume the role of a cosmetologist, toxicologist, nutritionist, and medical expert. The AI should analyze each ingredient in the provided list, its role, potential benefits, and any safety concerns.

    Steps:
    1. Identify each ingredient from the provided list.
    2. Determine the function of each ingredient (e.g., moisturizer, emulsifier, preservative, etc.).
    3. Provide a short description (1-2 sentences) of how each ingredient works and its impact on skin and health.
    4. Assess the danger level of each ingredient based on toxicity and potential health risks (low, medium, high).
    5. If an ingredient is unknown or has no available information, skip it.
    6. Answer should be given in RUSSIAN
    Sources:
    - Cosmetic Ingredient Review (CIR)
    - EWG's Skin Deep
    - INCI Decoder
    - FDA and ECHA regulations on cosmetic ingredients
    - Scientific research and publications

    Text to analyze: \(text)

    The result must be in the following JSON format:
    {"product_name": "Expected name of the product","description": "Brief 2-3 sentence overview of the product: what it is, what it does, and overall impression of its safety and quality","ingredients": [{"name":"Ingredient name","function": "Function of the ingredient","description": "Short description of how the ingredient works and its impact","danger_level": "Danger level of the ingredient (low, medium, high)"}],"full_composition": "Comma-separated list of all ingredients in the product","score": "Product score in scale 0..100"}
"""
    return prompt
}
