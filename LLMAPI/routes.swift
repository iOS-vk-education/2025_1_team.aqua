import Vapor

// Структуры для запроса
struct BotHubRequest: Content {
    let model: String
    let input: String
    let max_output_tokens: Int
}

// Функция для отправки запроса и  ответа
func analyzeText(text: String, app: Application) -> EventLoopFuture<String> {
    let apiKey = "api-key"  // API КЛЮЧ
    let url = "https://bothub.chat/api/v2/openai/v1/responses"
    
    var headers = HTTPHeaders()
    headers.add(name: .authorization, value: "Bearer \(apiKey)")
    headers.add(name: .contentType, value: "application/json")
    
    let body = BotHubRequest(model: "gpt-4o-mini", input: text, max_output_tokens: 3000)
    
    let client = app.client
    return client.post(URI(string: url), headers: headers, content: body)
        .flatMapThrowing { response in
            guard response.status == .ok else {
                let errorBody = String(buffer: response.body ?? ByteBuffer())
                app.logger.error(" API failed: \(errorBody)")
                throw Abort(.internalServerError, reason: "Error calling  API")
            }
            
            //  тело ответа
            let rawResponse = String(buffer: response.body ?? ByteBuffer())
            
            app.logger.info("Raw Response body: \(rawResponse)")  // Логируем raw ответ  API

            return rawResponse
        }
}

// Эндпоинт
func routes(_ app: Application) throws {
    // Эндпоинт для проверки работоспособности
    app.get("testt") { req -> String in
        return "Ok"
    }
    
    // Эндпоинт для анализа
    app.post("analyze") { req -> EventLoopFuture<String> in
        // Логируем запрос
        app.logger.info("Received request: \(req.body)")

        do {
            // Декодируем входящий запрос
            let analyzeRequest = try req.content.decode(AnalyzeRequest.self)
            app.logger.info("Decoded request: \(analyzeRequest)")  // Логируем декодированный запрос
            
            // Создаём запрос для AI
            let promptText = createPrompt(for: analyzeRequest.text)
            
            // Отправляем запрос в BotHub API и обрабатываем ответ
            return analyzeText(text: promptText, app: app)
        } catch {
            app.logger.error("Error decoding request: \(error)")
            throw Abort(.badRequest, reason: "Invalid request format")
        }
    }
}

// Структура для входящего запроса
struct AnalyzeRequest: Content {
    let text: String  
}

// Функция для создания запроса на основе текста
func createPrompt(for text: String) -> String {
    let prompt = """
    The AI should act as an expert in cosmetic ingredients, their impact on skin and human health. It should assume the role of a cosmetologist, toxicologist, nutritionist, and medical expert. The AI should analyze each ingredient in the list, its role, potential benefits, and any safety concerns.

    Steps:
    1. Identify each ingredient from the provided list.
    2. Determine the function of each ingredient (e.g., moisturizer, emulsifier, preservative, etc.).
    3. Provide a short description (1-2 sentences) of how each ingredient works and its impact on skin and health.
    4. Assess the danger level of each ingredient based on toxicity and potential health risks (low, medium, high).
    5. If an ingredient is unknown or has no available information, skip it.

    Sources:
    - Cosmetic Ingredient Review (CIR)
    - EWG’s Skin Deep
    - INCI Decoder
    - FDA and ECHA regulations on cosmetic ingredients
    - Scientific research and publications

    Text to analyze: \(text)

    The result must be in the following JSON format:
    {"product_name": "Expected name of the product","ingredients": [{"name":"Ingredient name","function": "Function of the ingredient","description": "Short description of how the ingredient works and its impact","danger_level": "Danger level of the ingredient (low, medium, high)"}],"full_composition": "Comma-separated list of all ingredients in the product","score": "Product score in scale 0..100"}
"""
    return prompt
}
