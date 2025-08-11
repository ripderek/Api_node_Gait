const pool = require("../db");
const Crear = async (req, res, next) => {
  let client;
  try {
    const { modelo } = req.body;
    client = await pool.connect(); // Obtener una conexión del pool
    const result = await client.query("select * from crearModeloID($1)", [
      modelo,
    ]);
    return res.status(200).json(result.rows[0].modeloid);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  } finally {
    if (client) client.release(); // Liberar la conexión
  }
};
const Editar = async (req, res, next) => {
  let client;
  try {
    const { modelo } = req.body;
    const { modeloid } = req.params;
    client = await pool.connect(); // Obtener una conexión del pool
    await client.query("call editarModelo($1,$2)", [modelo, modeloid]);
    return res.status(200).json({ message: "Se editó un modelo" });
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
    client = await pool.connect(); // Obtener una conexión del pool
    const result = await client.query("select * from listarModelos()");
    return res.status(200).json(result.rows);
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
  Editar,
};
