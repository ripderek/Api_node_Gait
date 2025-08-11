const pool = require("../db");

const listarMuestrasPersonas = async (req, res, next) => {
  let client;
  try {
    client = await pool.connect(); // Obtener una conexión del pool
    const result = await client.query("select * from listarMuestrasPersonas()");
    return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  } finally {
    if (client) client.release(); // Liberar la conexión
  }
};
const Crear = async (req, res, next) => {
  let client;
  try {
    const { Lista, modeloid } = req.body;

    // modeloid, personaid
    client = await pool.connect(); // Obtener una conexión del pool
    for (const item of Lista) {
      if (item.seleccionado) {
        // Solo los seleccionados
        await client.query("CALL relacionar_persona_modelo($1,$2)", [
          modeloid,
          item.personaid,
        ]);
      }
    }
    return res
      .status(200)
      .json({ message: "Se relacionó una persona con un modelo" });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  } finally {
    if (client) client.release(); // Liberar la conexión
  }
};

module.exports = {
  listarMuestrasPersonas,
  Crear,
};
