import '../models/content_pack.dart';
import '../models/game_mode.dart';
import '../models/tile.dart';

class TileCatalog {
  static const List<Tile> universal = [
    Tile(id: 101, type: TileType.drink, text: 'Bebe 1 trago'),
    Tile(id: 102, type: TileType.drink, text: 'Bebe 2 tragos'),
    Tile(id: 103, type: TileType.drink, text: 'Bebe 3 tragos'),
    Tile(id: 104, type: TileType.drink, text: 'Bebe 4 tragos'),
    Tile(id: 105, type: TileType.drink, text: 'Bebe tantos tragos como letras tenga tu nombre'),
    Tile(id: 106, type: TileType.drink, text: 'Bebe 2 tragos por cada vocal de tu nombre'),
    Tile(id: 107, type: TileType.groupDrink, text: 'Brindis obligatorio. Beben todos'),
    Tile(id: 108, type: TileType.groupDrink, text: 'Los dos jugadores con menos tragos beben 1'),
    Tile(id: 109, type: TileType.groupDrink, text: 'Los que lleven colores oscuros beben 2'),
    Tile(id: 110, type: TileType.groupDrink, text: 'Beben todos y el que termine último bebe otro'),
    Tile(id: 111, type: TileType.chaos, text: 'Elige quién bebe 4 tragos'),
    Tile(id: 112, type: TileType.chaos, text: 'El último en ponerse de pie bebe 3 tragos'),
    Tile(id: 113, type: TileType.chaos, text: 'Intercambia la bebida con la persona de tu derecha'),
    Tile(id: 114, type: TileType.chaos, text: 'El más serio bebe 2. Lo decide el grupo'),
    Tile(id: 115, type: TileType.chaos, text: 'Reparte 4 tragos como quieras'),
    Tile(id: 116, type: TileType.rule, text: 'Nueva regla'),
    Tile(id: 117, type: TileType.rule, text: 'Nueva regla'),
    Tile(id: 118, type: TileType.rule, text: 'Nueva regla'),
    Tile(id: 119, type: TileType.special, text: 'Retrocede 3 casillas', specialEffect: SpecialTileEffect.moveBack3),
    Tile(id: 120, type: TileType.special, text: 'Avanza otra vez el mismo número que sacaste', specialEffect: SpecialTileEffect.moveForwardByLastRoll),
    Tile(id: 121, type: TileType.special, text: 'Intercambia posición con otro jugador', specialEffect: SpecialTileEffect.swapWithPlayer),
    Tile(id: 122, type: TileType.special, text: '¡Vuelve a tirar! El dado es tuyo otra vez', specialEffect: SpecialTileEffect.rollAgain),
    Tile(id: 123, type: TileType.special, text: '¡Tirada extra! Lanza de nuevo', specialEffect: SpecialTileEffect.rollAgain),
    Tile(id: 801, type: TileType.wildcard, text: 'Comodín: el grupo inventa un reto ahora mismo'),
    Tile(id: 802, type: TileType.wildcard, text: 'Comodín: el jugador a tu izquierda decide qué haces'),
    Tile(id: 803, type: TileType.wildcard, text: 'Comodín: el grupo vota un reto para ti. Lo que diga la mayoría, va'),
  ];

  static const List<Tile> light = [
    Tile(id: 501, type: TileType.social, mode: GameMode.light, category: TileCategory.truth, text: 'Verdad: cuenta la anécdota más absurda que te haya pasado de fiesta'),
    Tile(id: 502, type: TileType.social, mode: GameMode.light, category: TileCategory.dare, text: 'Reto: habla durante una ronda con voz de locutor o bebe 2'),
    Tile(id: 503, type: TileType.social, mode: GameMode.light, category: TileCategory.neverHaveIEver, text: 'Nunca nunca: el que lo haya hecho bebe 2 tragos'),
    Tile(id: 504, type: TileType.social, mode: GameMode.light, category: TileCategory.actOut, text: 'Imitación: el grupo elige un famoso y tienes que imitarlo'),
    Tile(id: 505, type: TileType.social, mode: GameMode.light, text: 'Di algo bueno de cada jugador o bebe 1 por cada uno que te saltes'),
    Tile(id: 506, type: TileType.social, mode: GameMode.light, text: 'El de tu izquierda te pone un apodo para esta ronda'),
    Tile(id: 507, type: TileType.social, mode: GameMode.light, text: 'Cuenta tu peor chiste. Si nadie se ríe, bebe 2'),
    Tile(id: 508, type: TileType.social, mode: GameMode.light, text: '¿Quién acabaría antes perdiendo el móvil? El grupo decide'),
    Tile(id: 509, type: TileType.social, mode: GameMode.light, text: 'Confiesa un pequeño drama reciente o bebe 3'),
    Tile(id: 510, type: TileType.social, mode: GameMode.light, text: 'Haz una pose ridícula hasta que vuelva tu turno'),
    Tile(id: 511, type: TileType.social, mode: GameMode.light, text: 'La persona de tu derecha te hace una pregunta. Responde o bebe 3'),
    Tile(id: 512, type: TileType.social, mode: GameMode.light, text: 'Todos dicen una manía tuya. Si te enfadas, bebes 2'),
    Tile(id: 513, type: TileType.social, mode: GameMode.light, text: 'Haz reír al grupo. Si fallas, bebe 2'),
    Tile(id: 514, type: TileType.social, mode: GameMode.light, text: 'Di qué superpoder usarías esta noche y por qué'),
    Tile(id: 515, type: TileType.social, mode: GameMode.light, text: 'La persona más puntual reparte 2 tragos'),
    Tile(id: 516, type: TileType.social, mode: GameMode.light, text: 'Cuenta una anécdota vergonzosa del cole o bebe 3'),
    Tile(id: 517, type: TileType.social, mode: GameMode.light, text: 'Todos señalan al más probable de montar una bronca. Ese bebe 2'),
    Tile(id: 518, type: TileType.social, mode: GameMode.light, text: 'Haz una mini actuación como camarero borde'),
  ];

  static const List<Tile> spicy = [
    Tile(id: 601, type: TileType.social, mode: GameMode.spicy, category: TileCategory.truth, text: 'Verdad: ¿qué mensaje te arrepientes más de haber enviado?'),
    Tile(id: 602, type: TileType.social, mode: GameMode.spicy, category: TileCategory.dare, text: 'Reto: deja que el grupo elija tu foto de perfil hasta el próximo turno'),
    Tile(id: 603, type: TileType.social, mode: GameMode.spicy, category: TileCategory.neverHaveIEver, text: 'Nunca nunca picante: quien lo haya hecho bebe 3'),
    Tile(id: 604, type: TileType.social, mode: GameMode.spicy, category: TileCategory.actOut, text: 'Actuación: interpreta una cita desastrosa durante 20 segundos'),
    Tile(id: 605, type: TileType.social, mode: GameMode.spicy, text: 'Lee el último emoji que enviaste y explica el contexto o bebe 3'),
    Tile(id: 606, type: TileType.social, mode: GameMode.spicy, text: '¿Quién de aquí tiene más labia? El grupo decide'),
    Tile(id: 607, type: TileType.social, mode: GameMode.spicy, text: 'Confiesa tu peor cita o bebe 4'),
    Tile(id: 608, type: TileType.social, mode: GameMode.spicy, text: 'Todos votan en voz alta quién liga mejor. Esa persona reparte 3'),
    Tile(id: 609, type: TileType.social, mode: GameMode.spicy, text: 'Muestra la última búsqueda vergonzosa o bebe 3'),
    Tile(id: 610, type: TileType.social, mode: GameMode.spicy, text: 'Di quién de aquí te respondería antes a las 3 a.m.'),
    Tile(id: 611, type: TileType.social, mode: GameMode.spicy, text: 'Cuenta la mentira romántica más absurda que hayas dicho'),
    Tile(id: 612, type: TileType.social, mode: GameMode.spicy, text: 'Imita cómo ligarías con alguien del grupo sin decir su nombre'),
    Tile(id: 613, type: TileType.social, mode: GameMode.spicy, text: 'Confiesa algo que aún te da vergüenza recordar o bebe 4'),
    Tile(id: 614, type: TileType.social, mode: GameMode.spicy, text: 'El grupo elige una app y debes abrir la última notificación recibida o beber 3'),
    Tile(id: 615, type: TileType.social, mode: GameMode.spicy, text: 'Di el nombre de la peor red flag que has ignorado'),
    Tile(id: 616, type: TileType.social, mode: GameMode.spicy, text: 'Haz una escena de celos totalmente exagerada'),
    Tile(id: 617, type: TileType.social, mode: GameMode.spicy, text: 'Todos dicen quién sería peor ex. El más nombrado bebe 2'),
    Tile(id: 618, type: TileType.social, mode: GameMode.spicy, text: 'Cuenta qué persona te ha dejado más en visto'),
  ];

  static const List<Tile> wild = [
    Tile(id: 701, type: TileType.social, mode: GameMode.wild, category: TileCategory.truth, text: 'Verdad extrema: cuenta la mayor locura que has hecho por orgullo'),
    Tile(id: 702, type: TileType.social, mode: GameMode.wild, category: TileCategory.dare, text: 'Reto extremo: deja que el grupo te redacte un estado absurdo'),
    Tile(id: 703, type: TileType.social, mode: GameMode.wild, category: TileCategory.neverHaveIEver, text: 'Nunca nunca salvaje: quien lo haya hecho bebe 4'),
    Tile(id: 704, type: TileType.social, mode: GameMode.wild, category: TileCategory.actOut, text: 'Interpretación: actúa como villano de telenovela señalando a un traidor'),
    Tile(id: 705, type: TileType.social, mode: GameMode.wild, text: 'Di quién te cae peor en este momento o bebe 5'),
    Tile(id: 706, type: TileType.social, mode: GameMode.wild, text: 'El grupo te hace una pregunta y respondes sin filtro o bebes 5'),
    Tile(id: 707, type: TileType.social, mode: GameMode.wild, text: 'Confiesa la peor mentira que has sostenido demasiado tiempo'),
    Tile(id: 708, type: TileType.social, mode: GameMode.wild, text: 'Enséñale al grupo la última foto que te dio vergüenza guardar o bebe 5'),
    Tile(id: 709, type: TileType.social, mode: GameMode.wild, text: 'Haz una imitación dramática de alguien famoso en pleno escándalo'),
    Tile(id: 710, type: TileType.social, mode: GameMode.wild, text: 'Todos señalan a quien sería más caótico como compañero de piso. Ese bebe 3'),
    Tile(id: 711, type: TileType.social, mode: GameMode.wild, text: 'Cuenta qué harías con 1000 euros si nadie pudiera juzgarte'),
    Tile(id: 712, type: TileType.social, mode: GameMode.wild, text: 'Elige entre sinceridad total o beber 6'),
    Tile(id: 713, type: TileType.social, mode: GameMode.wild, text: 'Haz un discurso de ruptura inventado como si estuvieras en una película'),
    Tile(id: 714, type: TileType.social, mode: GameMode.wild, text: 'Di cuál ha sido tu peor impulso esta semana'),
    Tile(id: 715, type: TileType.social, mode: GameMode.wild, text: 'El grupo decide si tu historia es verdad o mentira. Si no te creen, bebes 4'),
    Tile(id: 716, type: TileType.social, mode: GameMode.wild, text: 'Cuenta la cosa más temeraria que harías por una apuesta'),
    Tile(id: 717, type: TileType.social, mode: GameMode.wild, text: 'Nombra a quien crees que se mete antes en un lío. Si coincide el grupo, bebe'),
    Tile(id: 718, type: TileType.social, mode: GameMode.wild, text: 'Actúa como si te hubieran pillado en una mentira gigantesca'),
  ];

  static const List<Tile> exToxico = [
    // SPICY
    Tile(id: 901, type: TileType.social, mode: GameMode.spicy, pack: ContentPack.exToxico,
        text: '¿Qué red flag viste clarísima y decidiste ignorar?'),
    Tile(id: 902, type: TileType.social, mode: GameMode.spicy, pack: ContentPack.exToxico,
        text: 'Cuenta una discusión absurda que tuviste en pareja.'),
    Tile(id: 903, type: TileType.social, mode: GameMode.spicy, pack: ContentPack.exToxico,
        text: '¿Alguna vez has cotilleado las redes de tu ex después de dejarlo? Confiesa.'),
    Tile(id: 904, type: TileType.social, mode: GameMode.spicy, pack: ContentPack.exToxico,
        text: '¿Te han dejado o has dejado más veces? Explica.'),
    Tile(id: 905, type: TileType.social, mode: GameMode.spicy, pack: ContentPack.exToxico,
        text: 'Cuenta algo que hiciste en una relación que repetirías sin dudarlo.'),

    // WILD
    Tile(id: 906, type: TileType.social, mode: GameMode.wild, pack: ContentPack.exToxico,
        text: '¿Volverías con tu ex si te escribe ahora mismo? Responde sin pensar.'),
    Tile(id: 907, type: TileType.social, mode: GameMode.wild, pack: ContentPack.exToxico,
        text: 'Cuenta lo más rastrero que hiciste por celos.'),
    Tile(id: 908, type: TileType.social, mode: GameMode.wild, pack: ContentPack.exToxico,
        text: '¿A quién de tus ex no soportas ver feliz? Di el nombre o bebe 3.'),
    Tile(id: 909, type: TileType.social, mode: GameMode.wild, pack: ContentPack.exToxico,
        text: '¿Alguna vez has hablado con alguien solo para dar celos a otra persona? Cuenta o bebe 3.'),
    Tile(id: 910, type: TileType.social, mode: GameMode.wild, pack: ContentPack.exToxico,
        text: 'Cuenta una mentira que dijiste en una relación y de la que nunca se enteraron.'),
    Tile(id: 911, type: TileType.social, mode: GameMode.wild, pack: ContentPack.exToxico,
        text: '¿Has mirado el móvil de alguien a escondidas? Cuenta qué encontraste o bebe 3.'),
    Tile(id: 912, type: TileType.social, mode: GameMode.wild, pack: ContentPack.exToxico,
        text: '¿A quién de aquí crees que sería el ex más tóxico? Señálalo.'),
    Tile(id: 913, type: TileType.social, mode: GameMode.wild, pack: ContentPack.exToxico,
        text: 'Cuenta lo más humillante que hiciste por alguien que te gustaba.'),
    Tile(id: 914, type: TileType.social, mode: GameMode.wild, pack: ContentPack.exToxico,
        text: '¿Alguna vez has vuelto con alguien solo por no estar solo? Cuenta o bebe 3.'),

    // CAOS
    Tile(id: 915, type: TileType.chaos, mode: GameMode.wild, pack: ContentPack.exToxico,
        text: 'Elige a alguien. Durante un turno sois ex tóxicos y discutís.'),
    Tile(id: 916, type: TileType.chaos, mode: GameMode.spicy, pack: ContentPack.exToxico,
        text: 'Todos dicen una red flag en 5 segundos. El que se quede en blanco, bebe.'),
  ];

  // Pack privado — solo se compila con: flutter build --dart-define=PRIVATE_PACK=true
  static const List<Tile> amigos = bool.fromEnvironment('PRIVATE_PACK')
      ? [
          // Pon aquí tus casillas cuando las tengas listas
          // Tile(id: 950, type: TileType.social, mode: GameMode.spicy, pack: ContentPack.amigos, text: '...'),
        ]
      : [];

  static const Tile finale = Tile(
    id: 999,
    type: TileType.finale,
    text: '¡BRONCOLA FINAL!',
  );
}
