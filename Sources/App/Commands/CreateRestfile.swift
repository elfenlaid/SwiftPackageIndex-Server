import SQLKit
import Vapor


enum Variant: String, LosslessStringConvertible {
    var description: String {
        rawValue
    }
    
    case all
    case active
    
    init(_ string: String) {
        self = Variant(rawValue: string) ?? .active
    }
}


struct CreateRestfileCommand: Command {
    struct Signature: CommandSignature {
        @Argument(name: "variant")
        var variant: Variant
    }
    
    var help: String { "Create restfile for automated testing" }
    
    func run(using context: CommandContext, signature: Signature) throws {
        guard let db = context.application.db as? SQLDatabase else {
            fatalError("Database must be an SQLDatabase ('as? SQLDatabase' must succeed)")
        }
        try createRestfile(on: db, variant: signature.variant).wait()
    }
}


func createRestfile(on database: SQLDatabase, variant: Variant) -> EventLoopFuture<Void> {
    let query: SQLQueryString
    switch variant {
        case .active:
            query = """
                    (
                    select '/' || repository_owner || '/' || repository_name as url
                      from recent_packages
                    union
                    select '/' || repository_owner || '/' || repository_name as url
                      from recent_releases
                    union
                    select '/' || r.owner || '/' || r.name as url
                      from packages p
                      join repositories r on r.package_id = p.id
                      where score > 50
                    )
                    order by url
                """
        case .all:
            query = """
                    select '/' || owner || '/' || name as url
                      from repositories
                      order by url
                """
    }
    struct Record: Decodable {
        var url: String
    }
    print("# auto-generated via `vapor run create-restfile \(variant.rawValue)`")
    print("mode: random")
    print("requests:")
    return database.raw(query)
        .all(decoding: Record.self)
        .mapEach { r in
            print("""
                \(r.url):
                  url: ${base_url}\(r.url)
                  validation:
                    status: 200
              """)
        }.transform(to: ())
}
