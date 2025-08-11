const pool = require("../db");
const Crear = async (req, res, next) => {
  let client;
  try {
    const { persona } = req.body;
    client = await pool.connect(); // Obtener una conexión del pool
    await client.query("call crearMuestra($1)", [persona]);
    return res.status(200).json({ message: "Se registró una muestra" });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  } finally {
    if (client) client.release(); // Liberar la conexión
  }
};

const Eliminar = async (req, res, next) => {
  let client;
  try {
    const { muestraid } = req.params;
    client = await pool.connect(); // Obtener una conexión del pool
    await client.query("call eliminarMuestra($1)", [muestraid]);
    return res.status(200).json({ message: "Se eliminó una muestra" });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  } finally {
    if (client) client.release(); // Liberar la conexión
  }
};

const Listar = async (req, res, next) => {
  let client;
  try {
    const { personaid } = req.params;
    client = await pool.connect(); // Obtener una conexión del pool
    const result = await client.query(
      "select * from obtener_persona_con_muestras($1)",
      [personaid]
    );
    return res.status(200).json(result.rows[0].obtener_persona_con_muestras[0]);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  } finally {
    if (client) client.release(); // Liberar la conexión
  }
};

module.exports = {
  Listar,
  Crear,
  Eliminar,
};

