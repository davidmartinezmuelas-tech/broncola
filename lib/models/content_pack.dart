enum ContentPack {
  base,
  exToxico,
  broncolaPlus,
  verguenzaAjena,
  caosTotal,
  amigos,
}

extension ContentPackInfo on ContentPack {
  String get label {
    switch (this) {
      case ContentPack.base:
        return 'Base';
      case ContentPack.exToxico:
        return 'Ex Tóxico';
      case ContentPack.broncolaPlus:
        return 'Broncola+';
      case ContentPack.verguenzaAjena:
        return 'Vergüenza Ajena';
      case ContentPack.caosTotal:
        return 'Caos Total';
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
      case ContentPack.broncolaPlus:
        return 'Dinero, trabajo, ambición y vida adulta. Preguntas que nadie hace en la oficina pero todos quieren responder.';
      case ContentPack.verguenzaAjena:
        return 'Momentos bochornosos, fases cringe y fallos sociales épicos. Para los que disfrutan del sufrimiento ajeno.';
      case ContentPack.caosTotal:
        return 'Decisiones impulsivas, retos absurdos y anarquía pura. El pack para cuando la noche ya no tiene remedio.';
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
      case ContentPack.broncolaPlus:
        return '💼';
      case ContentPack.verguenzaAjena:
        return '😬';
      case ContentPack.caosTotal:
        return '🔥';
      case ContentPack.amigos:
        return '👥';
    }
  }

  bool get isFree => this == ContentPack.base;

  /// Los packs privados no aparecen en la tienda ni están a la venta.
  /// Se desbloquean mediante un mecanismo oculto en el dispositivo.
  bool get isPrivate => this == ContentPack.amigos;
}
