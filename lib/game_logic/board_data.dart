import '../models/tile.dart';

class BoardData {
  static const List<Tile> tiles = [
    Tile(
        id: 0,
        type: TileType.social,
        text: '¡Inicio! Todos beben 1 trago de bienvenida'),
    Tile(id: 1, type: TileType.drink, text: 'Bebe 2 tragos'),
    Tile(id: 2, type: TileType.social, text: 'Verdad o reto: elige uno'),
    Tile(id: 3, type: TileType.groupDrink, text: '¡Beben todos!'),
    Tile(id: 4, type: TileType.rule, text: 'Nueva regla: prohibido decir "sí"'),
    Tile(id: 5, type: TileType.drink, text: 'Bebe 3 tragos'),
    Tile(id: 6, type: TileType.chaos, text: 'Elige quién bebe 4 tragos'),
    Tile(
        id: 7,
        type: TileType.social,
        text: 'El jugador a tu izquierda bebe 2 tragos'),
    Tile(id: 8, type: TileType.drink, text: 'Bebe 1 trago'),
    Tile(id: 9, type: TileType.groupDrink, text: 'Los hombres beben 2 tragos'),
    Tile(
        id: 10,
        type: TileType.social,
        text: 'Nunca nunca: el que lo haya hecho bebe 3 tragos'),
    Tile(
        id: 11,
        type: TileType.rule,
        text: 'Nueva regla: hablar en tercera persona'),
    Tile(
        id: 12,
        type: TileType.drink,
        text: 'Bebe tantos tragos como letras tenga tu nombre'),
    Tile(
        id: 13,
        type: TileType.chaos,
        text: 'Intercambia la bebida con el jugador de tu derecha'),
    Tile(id: 14, type: TileType.groupDrink, text: 'Las mujeres beben 2 tragos'),
    Tile(
        id: 15,
        type: TileType.social,
        text: '¿Quién miente mejor? El grupo decide, el resto bebe'),
    Tile(
        id: 16,
        type: TileType.drink,
        text: 'Bebe 2 tragos por cada vocal de tu nombre'),
    Tile(
        id: 17,
        type: TileType.chaos,
        text: '¡Caos! Todos cambian de sitio, el último bebe'),
    Tile(
        id: 18,
        type: TileType.rule,
        text: 'Nueva regla: no señalar con el dedo'),
    Tile(id: 19, type: TileType.drink, text: 'Bebe 3 tragos'),
    Tile(
        id: 20,
        type: TileType.groupDrink,
        text: '¡Brindis obligatorio! Beben todos'),
    Tile(id: 21, type: TileType.social, text: 'Di un secreto o bebe 5 tragos'),
    Tile(id: 22, type: TileType.drink, text: 'Bebe 2 tragos'),
    Tile(
        id: 23,
        type: TileType.chaos,
        text: 'El último en reírse reparte 4 tragos'),
    Tile(id: 24, type: TileType.rule, text: 'Nueva regla: hablar susurrando'),
    Tile(
        id: 25,
        type: TileType.social,
        text: 'Imita a otro jugador, si adivinan bebes tú'),
    Tile(id: 26, type: TileType.drink, text: 'Bebe 4 tragos'),
    Tile(id: 27, type: TileType.groupDrink, text: '¡Shot grupal! Beben todos'),
    Tile(
        id: 28,
        type: TileType.chaos,
        text: 'El último en ponerse de pie bebe 3 tragos'),
    Tile(
        id: 29,
        type: TileType.social,
        text: 'Inventa una regla nueva o bebe 3 tragos'),
    Tile(id: 30, type: TileType.drink, text: 'Bebe 1 trago'),
    Tile(
        id: 31,
        type: TileType.rule,
        text: 'Nueva regla: no decir nombres propios'),
    Tile(
        id: 32,
        type: TileType.chaos,
        text: 'El más serio bebe 2 tragos, lo decide el grupo'),
    Tile(
        id: 33,
        type: TileType.groupDrink,
        text: 'Beben los que lleven ropa de colores'),
    Tile(
        id: 34,
        type: TileType.social,
        text: '¿Quién es el más valiente? El grupo elige, bebe el tímido'),
    Tile(id: 35, type: TileType.drink, text: 'Bebe 2 tragos'),
    Tile(
        id: 36,
        type: TileType.rule,
        text: 'Nueva regla: no usar el móvil o bebes'),
    Tile(
        id: 37,
        type: TileType.chaos,
        text: 'Ruleta: el jugador a tu derecha elige cuánto bebes (1–4)'),
    Tile(
        id: 38,
        type: TileType.social,
        text: 'Haz reír a alguien o bebe 3 tragos'),
    Tile(
        id: 39,
        type: TileType.groupDrink,
        text: 'Los que tienen pelo largo beben 2 tragos'),
    Tile(id: 40, type: TileType.finale, text: '¡BRONCOLA FINAL!'),
  ];
}
