import CoreData
import Foundation

// MARK: - NSManagedObject subclasses

@objc(ProductEntity)
final class ProductEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var score: Int32
    @NSManaged var productDescription: String
    @NSManaged var fullComposition: String
    @NSManaged var scanDate: Date
    @NSManaged var ingredients: NSOrderedSet
}

@objc(IngredientEntity)
final class IngredientEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var role: String
    @NSManaged var impact: String
    @NSManaged var riskLevel: String
    @NSManaged var product: ProductEntity?
}

// MARK: - PersistenceController

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    private init() {
        container = NSPersistentContainer(name: "Purely", managedObjectModel: Self.makeModel())
        container.loadPersistentStores { _, error in
            if let error { fatalError("CoreData load failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Public API

    func fetchProducts() -> [Product] {
        let request = NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "scanDate", ascending: false)]
        return (try? context.fetch(request))?.map { $0.toProduct() } ?? []
    }

    func save(product: Product) {
        let entity = ProductEntity(context: context)
        entity.id                 = product.id
        entity.name               = product.name
        entity.score              = Int32(product.score)
        entity.productDescription = product.description
        entity.fullComposition    = product.full_composition
        entity.scanDate           = Date()

        let ingEntities = product.ingredients.map { ing -> IngredientEntity in
            let e       = IngredientEntity(context: context)
            e.id        = ing.id
            e.name      = ing.name
            e.role      = ing.role
            e.impact    = ing.impact
            e.riskLevel = ing.riskLevel.rawValue
            e.product   = entity
            return e
        }
        entity.ingredients = NSOrderedSet(array: ingEntities)
        saveContext()
    }

    func delete(product: Product) {
        let request = NSFetchRequest<ProductEntity>(entityName: "ProductEntity")
        request.predicate = NSPredicate(format: "id == %@", product.id as CVarArg)
        guard let entity = try? context.fetch(request).first else { return }
        context.delete(entity)
        saveContext()
    }

    // MARK: - Private

    private func saveContext() {
        guard context.hasChanges else { return }
        try? context.save()
    }

    // MARK: - Programmatic Model (без .xcdatamodeld файла)

    private static func makeModel() -> NSManagedObjectModel {
        let prodEntity = NSEntityDescription()
        prodEntity.name = "ProductEntity"
        prodEntity.managedObjectClassName = "ProductEntity"

        let ingEntity = NSEntityDescription()
        ingEntity.name = "IngredientEntity"
        ingEntity.managedObjectClassName = "IngredientEntity"

        let prodToIng = NSRelationshipDescription()
        prodToIng.name = "ingredients"
        prodToIng.destinationEntity = ingEntity
        prodToIng.isOrdered = true
        prodToIng.minCount = 0
        prodToIng.maxCount = 0
        prodToIng.deleteRule = .cascadeDeleteRule

        let ingToProd = NSRelationshipDescription()
        ingToProd.name = "product"
        ingToProd.destinationEntity = prodEntity
        ingToProd.minCount = 0
        ingToProd.maxCount = 1
        ingToProd.deleteRule = .nullifyDeleteRule

        prodToIng.inverseRelationship = ingToProd
        ingToProd.inverseRelationship = prodToIng

        prodEntity.properties = [
            makeAttr("id",                 .UUIDAttributeType),
            makeAttr("name",               .stringAttributeType),
            makeAttr("score",              .integer32AttributeType),
            makeAttr("productDescription", .stringAttributeType),
            makeAttr("fullComposition",    .stringAttributeType),
            makeAttr("scanDate",           .dateAttributeType),
            prodToIng
        ]

        ingEntity.properties = [
            makeAttr("id",        .UUIDAttributeType),
            makeAttr("name",      .stringAttributeType),
            makeAttr("role",      .stringAttributeType),
            makeAttr("impact",    .stringAttributeType),
            makeAttr("riskLevel", .stringAttributeType),
            ingToProd
        ]

        let model = NSManagedObjectModel()
        model.entities = [prodEntity, ingEntity]
        return model
    }

    private static func makeAttr(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
        let attr = NSAttributeDescription()
        attr.name = name
        attr.attributeType = type
        attr.isOptional = true
        return attr
    }
}

// MARK: - ProductEntity → Product

extension ProductEntity {
    func toProduct() -> Product {
        let ings = (ingredients.array as? [IngredientEntity] ?? []).map { e in
            Ingredient(
                id: e.id,
                name: e.name,
                role: e.role,
                impact: e.impact,
                riskLevel: RiskLevel(rawValue: e.riskLevel) ?? .medium
            )
        }
        return Product(
            id: id,
            name: name,
            score: Int(score),
            description: productDescription,
            ingredients: ings,
            full_composition: fullComposition
        )
    }
}
