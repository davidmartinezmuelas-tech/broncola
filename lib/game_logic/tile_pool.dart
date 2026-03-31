import '../models/tile.dart';
import '../models/game_mode.dart';

/// Todos los tiles del juego organizados por modo.
/// mode: null  → universal (aparece en todos los modos)
/// mode: light → solo modo Tranquilo y Picante
/// mode: spicy → solo modo Picante
/// mode: wild  → solo modo Extremo
class TilePool {
  // ─── UNIVERSALES (mecánicas de beber) ────────────────────────────────────
  static const List<Tile> universal = [
    // Drink
    Tile(id: 101, type: TileType.drink, text: 'Bebe 1 trago', mode: null),
    Tile(id: 102, type: TileType.drink, text: 'Bebe 2 tragos', mode: null),
    Tile(id: 103, type: TileType.drink, text: 'Bebe 3 tragos', mode: null),
    Tile(id: 104, type: TileType.drink, text: 'Bebe 4 tragos', mode: null),
    Tile(
        id: 105,
        type: TileType.drink,
        text: 'Bebe tantos tragos como letras tenga tu nombre',
        mode: null),
    Tile(
        id: 106,
        type: TileType.drink,
        text: 'Bebe 2 tragos por cada vocal de tu nombre',
        mode: null),
    // GroupDrink
    Tile(id: 201, type: TileType.groupDrink, text: '¡Beben todos!', mode: null),
    Tile(
        id: 202,
        type: TileType.groupDrink,
        text: 'Los hombres beben 2 tragos',
        mode: null),
    Tile(
        id: 203,
        type: TileType.groupDrink,
        text: 'Las mujeres beben 2 tragos',
        mode: null),
    Tile(
        id: 204,
        type: TileType.groupDrink,
        text: '¡Brindis obligatorio! Beben todos',
        mode: null),
    Tile(
        id: 205,
        type: TileType.groupDrink,
        text: '¡Shot grupal! Beben todos',
        mode: null),
    Tile(
        id: 206,
        type: TileType.groupDrink,
        text: 'Beben los que lleven ropa de colores',
        mode: null),
    Tile(
        id: 207,
        type: TileType.groupDrink,
        text: 'Los que tienen pelo largo beben 2 tragos',
        mode: null),
    // Chaos
    Tile(
        id: 301,
        type: TileType.chaos,
        text: 'Elige quién bebe 4 tragos',
        mode: null),
    Tile(
        id: 302,
        type: TileType.chaos,
        text: 'Intercambia la bebida con el jugador de tu derecha',
        mode: null),
    Tile(
        id: 303,
        type: TileType.chaos,
        text: '¡Caos! Todos cambian de sitio, el último bebe',
        mode: null),
    Tile(
        id: 304,
        type: TileType.chaos,
        text: 'El último en reírse reparte 4 tragos',
        mode: null),
    Tile(
        id: 305,
        type: TileType.chaos,
        text: 'El último en ponerse de pie bebe 3 tragos',
        mode: null),
    Tile(
        id: 306,
        type: TileType.chaos,
        text: 'Ruleta: el jugador a tu derecha elige cuánto bebes (1–4)',
        mode: null),
    Tile(
        id: 307,
        type: TileType.chaos,
        text: 'El más serio bebe 2 tragos, lo decide el grupo',
        mode: null),
    // Rule (el jugador escribe la suya)
    Tile(id: 401, type: TileType.rule, text: 'Nueva regla', mode: null),
    Tile(id: 402, type: TileType.rule, text: 'Nueva regla', mode: null),
    Tile(id: 403, type: TileType.rule, text: 'Nueva regla', mode: null),
  ];

  // ─── LIGHT ───────────────────────────────────────────────────────────────
  static const List<Tile> light = [
    Tile(
        id: 501,
        type: TileType.social,
        mode: GameMode.light,
        text: 'Verdad o reto: el grupo elige'),
    Tile(
        id: 502,
        type: TileType.social,
        mode: GameMode.light,
        text: 'Nunca nunca: el que lo haya hecho bebe 3 tragos'),
    Tile(
        id: 503,
        type: TileType.social,
        mode: GameMode.light,
        text: '¿Quién miente mejor? El grupo decide, el resto bebe'),
    Tile(
        id: 504,
        type: TileType.social,
        mode: GameMode.light,
        text: 'Di un secreto o bebe 5 tragos'),
    Tile(
        id: 505,
        type: TileType.social,
        mode: GameMode.light,
        text: 'Imita a otro jugador, si adivinan bebes tú'),
    Tile(
        id: 506,
        type: TileType.social,
        mode: GameMode.light,
        text: 'Inventa una regla nueva o bebe 3 tragos'),
    Tile(
        id: 507,
        type: TileType.social,
        mode: GameMode.light,
        text: 'Haz reír a alguien en 30 segundos o bebe 3 tragos'),
    Tile(
        id: 508,
        type: TileType.social,
        mode: GameMode.light,
        text: 'Di el peor chiste que sepas o bebe 2 tragos'),
    Tile(
        id: 509,
        type: TileType.social,
        mode: GameMode.light,
        text: 'Cuenta una anécdota vergonzosa o bebe 3 tragos'),
    Tile(
        id: 510,
        type: TileType.social,
        mode: GameMode.light,
        text:
            'Todos dicen algo que nunca contarían a sus padres. El más tímido bebe'),
    Tile(
        id: 511,
        type: TileType.social,
        mode: GameMode.light,
        text:
            '¿Quién tiene más posibilidades de acabar la noche mal? El grupo vota, bebe el elegido'),
    Tile(
        id: 512,
        type: TileType.social,
        mode: GameMode.light,
        text:
            'El jugador a tu izquierda te hace una pregunta. Responde o bebe 3'),
    Tile(
        id: 513,
        type: TileType.social,
        mode: GameMode.light,
        text: 'Adivina quién del grupo te tiene más manía. Si fallas, bebe 2'),
    Tile(
        id: 514,
        type: TileType.social,
        mode: GameMode.light,
        text:
            'Pon un apodo al jugador de tu derecha. Si no acepta el apodo, bebes tú'),
    Tile(
        id: 515,
        type: TileType.social,
        mode: GameMode.light,
        text:
            'Di algo bueno de cada jugador o bebe 1 trago por cada uno que te saltes'),
  ];

  // ─── SPICY ───────────────────────────────────────────────────────────────
  static const List<Tile> spicy = [
    Tile(
        id: 601,
        type: TileType.social,
        mode: GameMode.spicy,
        text:
            'Di el nombre de alguien de aquí con quien podrías salir. Si pasas, bebe 3'),
    Tile(
        id: 602,
        type: TileType.social,
        mode: GameMode.spicy,
        text:
            '¿Cuál es la cosa más vergonzosa que has hecho borracho/a? Si no lo dices, bebe 4'),
    Tile(
        id: 603,
        type: TileType.social,
        mode: GameMode.spicy,
        text:
            '¿A quién de aquí mandarías un mensaje a las 3am? Si pasas, bebe 3'),
    Tile(
        id: 604,
        type: TileType.social,
        mode: GameMode.spicy,
        text:
            'Intercambia el móvil con el jugador de tu izquierda durante 1 minuto'),
    Tile(
        id: 605,
        type: TileType.social,
        mode: GameMode.spicy,
        text:
            'Muestra el último emoji que enviaste y explica el contexto o bebe 3'),
    Tile(
        id: 606,
        type: TileType.social,
        mode: GameMode.spicy,
        text:
            'Lee en voz alta el último mensaje que recibiste o bebe 4 tragos'),
    Tile(
        id: 607,
        type: TileType.social,
        mode: GameMode.spicy,
        text: 'Votación: ¿quién de aquí liga más? El elegido reparte 4 tragos'),
    Tile(
        id: 608,
        type: TileType.social,
        mode: GameMode.spicy,
        text:
            'Todos dicen en voz alta el nombre de su ex. El que tarde más bebe 3'),
    Tile(
        id: 609,
        type: TileType.social,
        mode: GameMode.spicy,
        text: '¿Cuál ha sido tu peor cita? Cuéntalo o bebe 4 tragos'),
    Tile(
        id: 610,
        type: TileType.social,
        mode: GameMode.spicy,
        text: 'Llama a alguien de tu lista de contactos o bebe 5 tragos'),
    Tile(
        id: 611,
        type: TileType.social,
        mode: GameMode.spicy,
        text: 'Enseña el chat más comprometido de tu móvil o bebe 4 tragos'),
    Tile(
        id: 612,
        type: TileType.social,
        mode: GameMode.spicy,
        text: 'Di la cosa más loca que has hecho por alguien o bebe 3 tragos'),
    Tile(
        id: 613,
        type: TileType.social,
        mode: GameMode.spicy,
        text: 'Confiesa algo que nunca le has dicho a nadie aquí o bebe 5'),
    Tile(
        id: 614,
        type: TileType.social,
        mode: GameMode.spicy,
        text:
            '¿Quién de aquí tiene más secretos? El grupo decide, bebe el elegido'),
    Tile(
        id: 615,
        type: TileType.social,
        mode: GameMode.spicy,
        text:
            'El jugador a tu derecha lee tu último estado de WhatsApp en voz alta o bebes 3'),
  ];

  // ─── WILD ────────────────────────────────────────────────────────────────
  static const List<Tile> wild = [
    Tile(
        id: 701,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'Di el peor pensamiento que has tenido sobre alguien de aquí o bebe 6 tragos'),
    Tile(
        id: 702,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'Elige a alguien para que vea tus últimas búsquedas en Google. Si te niegas, bebe 6'),
    Tile(
        id: 703,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'Confiesa algo que harías por dinero. El grupo vota si es suficientemente salvaje o bebes 4'),
    Tile(
        id: 704,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            '¿A quién de aquí nunca le prestarías dinero? Dilo en voz alta o bebe 5'),
    Tile(
        id: 705,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'Enseña la última foto de tu galería sin mirarla antes. Si te niegas, bebe 5'),
    Tile(
        id: 706,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'El grupo decide la mentira más grande que has dicho esta noche. El elegido bebe 5'),
    Tile(
        id: 707,
        type: TileType.social,
        mode: GameMode.wild,
        text: 'Llama a tu ex y di "te echo de menos" o bebe 6 tragos'),
    Tile(
        id: 708,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'Di en voz alta lo que realmente piensas del jugador a tu derecha. Sin filtros o bebe 5'),
    Tile(
        id: 709,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'Pon tu móvil boca arriba en la mesa 5 minutos. Si alguien lo toca, bebe. Si te niegas, bebes tú 6'),
    Tile(
        id: 710,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            '¿Cuál es el mayor secreto que guardas de alguien del grupo? Da una pista o bebe 5'),
    Tile(
        id: 711,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'Confiesa la peor cosa que has hecho sin que nadie se enterara. Si pasas, bebe 6'),
    Tile(
        id: 712,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            '¿Quién de aquí te cae peor en este momento? Dilo o bebe 6 tragos'),
    Tile(
        id: 713,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'Bloquea a alguien de tu lista de contactos hasta mañana o bebe 6 tragos'),
    Tile(
        id: 714,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'El grupo te hace una pregunta que debes responder con total honestidad o bebes 6'),
    Tile(
        id: 715,
        type: TileType.social,
        mode: GameMode.wild,
        text:
            'Di quién del grupo crees que más miente. El grupo vota si aciertas. Si fallas, bebes 5'),
  ];

  static const Tile finale = Tile(
    id: 999,
    type: TileType.finale,
    text: '¡BRONCOLA FINAL!',
    mode: null,
  );
}
