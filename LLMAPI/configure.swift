import Vapor

public func configure(_ app: Application) async throws {

    app.http.server.configuration.hostname = "0.0.0.0"  // Слушаем на всех интерфейсах
    app.http.server.configuration.port = 8080 // порт

    // register routes
    try routes(app)
}
