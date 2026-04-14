import Vapor

public func configure(_ app: Application) async throws {

    app.http.server.configuration.hostname = "0.0.0.0"
    let port = Environment.get("PORT").flatMap(Int.init) ?? 8080
    app.http.server.configuration.port = port

    try routes(app)
}
