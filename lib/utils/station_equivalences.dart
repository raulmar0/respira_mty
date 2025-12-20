class StationEquivalences {
  static const Map<String, List<String>> equivalencias = {
    'SURESTE': ['Guadalupe, La Pastora', 'SURESTE'],
    'NORESTE': ['San Nicolás, Unidad Laboral', 'NORESTE'],
    'CENTRO': ['Monterrey, Obispado', 'CENTRO'],
    'NOROESTE': ['Monterrey, San Bernabé', 'NOROESTE'],
    'SUROESTE': ['Santa Catarina, Centro', 'SUROESTE'],
    'NORTE': ['Escobedo, Santa Luz', 'NORTE'],
    'GARCIA': ['García, Sierra Leal', 'NOROESTE2'],
    'NORESTE2': ['Apodaca, Centro', 'NORESTE2'],
    'SURESTE2': ['Juarez, Centro', 'SURESTE2'],
    '%5BSAN%20Pedro%5D': ['San Pedro, Los Sauces', 'SUROESTE2'],
    'SURESTE3': ['Cadereyta, Jerónimo Treviño', 'SURESTE3'],
    'SUR': ['Monterrey, Pueblo Serena', 'SUR'],
    'NORTE2': ['San Nicolás, CEDEEM', 'NORTE2'],
    'PESQUERIA': ['Pesquería', 'ESTE'],
    'NOROESTE3': ['García, Arco Vial', 'NOROESTE3'],
  };

  static List<String> findMatch(String title) {
    return equivalencias[title] ?? ['Sin nombre', ''];
  }
}