const { Router } = require("express");
const router = Router();
const { Crear, Listar, Editar } = require("../controllers/modelos");

router.post("/", Crear);
router.get("/", Listar);
router.put("/:modeloid", Editar);

module.exports = router;
