const { Router } = require("express");
const router = Router();
const {
  listarMuestrasPersonas,
  Crear,
} = require("../controllers/muestras_personas");

router.get("/", listarMuestrasPersonas);
router.post("/", Crear);

module.exports = router;
