const { Router } = require("express");
const router = Router();
const { Crear, Listar, Eliminar } = require("../controllers/muestras");

router.post("/", Crear);
router.get("/:personaid", Listar);
router.delete("/:muestraid", Eliminar);

module.exports = router;
