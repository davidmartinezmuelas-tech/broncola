enum ContentPack {
  base,
  exToxico,
  amigos,
  // Próximos packs:
  // broncolaPlus,
  // verguenzaAjena,
  // caosTotal,
}

extension ContentPackInfo on ContentPack {
  String get label {
    switch (this) {
      case ContentPack.base:
        return 'Base';
      case ContentPack.exToxico:
        return 'Ex Tóxico';
      case ContentPack.amigos:
        return 'Amigos';
    }
  }

  String get description {
    switch (this) {
      case ContentPack.base:
        return 'Contenido gratuito incluido en Broncola.';
      case ContentPack.exToxico:
        return 'Ese pack que saca lo peor de tus relaciones pasadas. Confesiones incómodas, decisiones cuestionables y verdades que no querías decir.';
      case ContentPack.amigos:
        return 'Pack privado.';
    }
  }

  String get emoji {
    switch (this) {
      case ContentPack.base:
        return '🎮';
      case ContentPack.exToxico:
        return '💔';
      case ContentPack.amigos:
        return '👥';
    }
  }

  bool get isFree => this == ContentPack.base;

  /// Los packs privados no aparecen en la tienda ni están a la venta.
  /// Se desbloquean mediante un mecanismo oculto en el dispositivo.
  bool get isPrivate => this == ContentPack.amigos;
}
