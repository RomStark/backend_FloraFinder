import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "floraFinder_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "floraFinder_password",
        database: Environment.get("DATABASE_NAME") ?? "floraFinder_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateDrug())
    app.migrations.add(CreatePlant())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserDrug())
    app.migrations.add(CreateUserPlant())
    try await app.autoMigrate().get()

    // register routes
    try routes(app)
}
