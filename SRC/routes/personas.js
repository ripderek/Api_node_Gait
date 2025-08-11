const { Router } = require("express");
const router = Router();
const { Crear, Listar, Eliminar, Editar } = require("../controllers/personas");

router.post("/", Crear);
router.get("/", Listar);
router.delete("/:personaid", Eliminar);
router.put("/:personaid", Editar);

module.exports = router;
