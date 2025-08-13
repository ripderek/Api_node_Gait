--crear la tabla personas con un identity 

create table personas(
	personaid BIGSERIAL PRIMARY KEY,
	persona text not null unique,
	fecha timestamp default now() not null
);

--crear procedimiento para insertar a la persona
--call crearPersona('Michell');
CREATE OR REPLACE PROCEDURE public.crearPersona(
	in persona_p text
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	insert into personas(persona) values (persona_p);	
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;

--crear procedimiento para editar a la persona
CREATE OR REPLACE PROCEDURE public.editarPersona(
	in persona_p text,
	in personaid_p bigint
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	update personas set persona=persona_p where personaid=personaid_p;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;

--crear procedimiento para eliminar a la persona (tener en cuenta las muestras)
CREATE OR REPLACE PROCEDURE public.eliminarPersona(
	in personaid_p bigint
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	delete from personas where  personaid=personaid_p;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;

--crear funcion para listar a las personas
CREATE OR REPLACE FUNCTION public.listarPersonas()
 RETURNS TABLE(
  personaid bigint, persona text, fecha text, hora_minutos text
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select p.personaid,p.persona,TO_CHAR(COALESCE(p.fecha, CURRENT_DATE), 'DD/MM/YYYY') ,
			 TO_CHAR(COALESCE(p.fecha, CURRENT_DATE), 'HH24:MI') from personas p;
end;
$function$
;

--select * from listarPersonas()


-------------------------------------[/* MUESTRAS *\]----------------------------------------------------


--crear la tabla de muestras y entrenamiento

create table muestras(
	muestraid BIGSERIAL PRIMARY KEY,
	personaid bigint not null,
	fecha timestamp default now() not null,
	CONSTRAINT fk_persona_muestra
        FOREIGN KEY (personaid)
        REFERENCES personas(personaid)
);

--procedimiento para crear una muestra
--call crearMuestra(4)
CREATE OR REPLACE PROCEDURE public.crearMuestra(
	in personaid_p bigint
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	insert into muestras(personaid) values (personaid_p);	
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;
--procedimiento para eliminar una muestra de una persona pero teniendo en cuenta los foreing key
CREATE OR REPLACE PROCEDURE public.eliminarMuestra(
	in muestraid_p bigint
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	delete from muestras where  muestraid=muestraid_p;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;
--funcion para listar las muestras
--select m.muestraid,m.personaid,m.fecha,p.persona,p.personaid from muestras m inner join personas p on p.personaid=m.personaid where p.personaid=4
--select * from obtener_persona_con_muestras(4)
CREATE OR REPLACE FUNCTION obtener_persona_con_muestras(p_id INT)
RETURNS JSON AS $$
BEGIN
  RETURN (
    SELECT json_agg(
      json_build_object(
        'personaid', p.personaid,
        'persona', p.persona,
        'muestras', COALESCE((
          SELECT json_agg(
            json_build_object(
              'muestraid', m.muestraid,
              'fecha', TO_CHAR(COALESCE(m.fecha, CURRENT_DATE), 'DD/MM/YYYY'),
              'Hora_Minutos', TO_CHAR(COALESCE(m.fecha, CURRENT_DATE), 'HH24:MI'),
			  'TieneDatos', EXISTS (
              SELECT 1
              FROM entrenamiento e
              WHERE e.muestraid = m.muestraid
          		)
            )
          )
          FROM muestras m
          WHERE m.personaid = p.personaid
        ), '[]'::json)
      )
    )
    FROM personas p
    WHERE p.personaid = p_id
  );
END;
$$ LANGUAGE plpgsql;

--select * from entrenamiento e where e.muestraid = 28


--crear una tabla para el entrenamiento del modelo
--crear una tabla para registrar videos y una funcion para registrarlo y obtener el id

create table videos_muestras(
	videoid BIGSERIAL PRIMARY KEY,
	muestraid bigint not null,
	fecha timestamp default now() not null,
	CONSTRAINT fk_video_muestra
        FOREIGN KEY (muestraid)
        REFERENCES muestras(muestraid)
);


--funcion para registrar un video y que devuelva el id 
--select videoid from registrar_obtener_id_muestra_video()

CREATE OR REPLACE FUNCTION public.registrar_obtener_id_muestra_video(muestraid_p bigint)
 RETURNS TABLE(
  videoid bigint
 )
 LANGUAGE plpgsql
AS $function$
begin

	--registrar el video 
	insert into videos_muestras(muestraid) values (muestraid_p);

	return query
	select v.videoid from videos_muestras v where v.muestraid=muestraid_p  order by v.videoid desc limit 1; 

end;
$function$
;


select * from videos_muestras











---Eliminar porque por cada punto es promedio y desviacion 




--ahora si crear la tabla de entrenamiento para registrar las muestras para el entrenamiento
--drop table entrenamiento
--select * from entrenamiento
create table entrenamiento(
	videoid bigint not null,
	muestraid bigint not null,
	fecha timestamp default now() not null,
	/*LOS PUNTOS*/
	p_32_31_promedio   NUMERIC(20, 14) not null,
	p_32_31_desviacion NUMERIC(20, 14) not null,
	p_28_27_promedio   NUMERIC(20, 14) not null,
	p_28_27_desviacion NUMERIC(20, 14) not null,
	p_26_25_promedio   NUMERIC(20, 14) not null,
	p_26_25_desviacion NUMERIC(20, 14) not null,
	p_31_23_promedio   NUMERIC(20, 14) not null,
	p_31_23_desviacion NUMERIC(20, 14) not null,
	p_32_24_promedio   NUMERIC(20, 14) not null,
	p_32_24_desviacion NUMERIC(20, 14) not null,
	CONSTRAINT fk_entrenamiento_muestra
        FOREIGN KEY (muestraid)
        REFERENCES muestras(muestraid),
    CONSTRAINT fk_video_entrenamienta
        FOREIGN KEY (videoid)
        REFERENCES videos_muestras(videoid)
);


---procedimiento para registrar los puntos de la muestra
--call registrar_puntos_muestra($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
CREATE OR REPLACE PROCEDURE public.registrar_puntos_muestra(
	in videoid_p bigint,
	in muestraid_p bigint,
	in p_32_31_promedio_p   NUMERIC(20, 14),
	in p_32_31_desviacion_p NUMERIC(20, 14),
	in p_28_27_promedio_p   NUMERIC(20, 14),
	in p_28_27_desviacion_p NUMERIC(20, 14),
	in p_26_25_promedio_p   NUMERIC(20, 14),
	in p_26_25_desviacion_p NUMERIC(20, 14),
	in p_31_23_promedio_p   NUMERIC(20, 14),
	in p_31_23_desviacion_p NUMERIC(20, 14),
	in p_32_24_promedio_p   NUMERIC(20, 14),
	in p_32_24_desviacion_p NUMERIC(20, 14)
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	insert into entrenamiento(videoid,muestraid,
		p_32_31_promedio,
		p_32_31_desviacion,
		p_28_27_promedio,
		p_28_27_desviacion,
		p_26_25_promedio,
		p_26_25_desviacion,
		p_31_23_promedio,
		p_31_23_desviacion,
		p_32_24_promedio,
		p_32_24_desviacion
		)
	values (videoid_p,muestraid_p,
		p_32_31_promedio_p,
		p_32_31_desviacion_p,
		p_28_27_promedio_p,
		p_28_27_desviacion_p,
		p_26_25_promedio_p,
		p_26_25_desviacion_p,
		p_31_23_promedio_p,
		p_31_23_desviacion_p,
		p_32_24_promedio_p,
		p_32_24_desviacion_p
		);	

EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;


--

--ahora hacer la funcion que devuelva los datos de entrenamiento en formato JSON para crear el modelo 

select 
 ROW_NUMBER() OVER (ORDER BY e.videoid) as muestra_id,
p.persona,
e.p_32_31_promedio,
e.p_32_31_desviacion,
e.p_28_27_promedio,
e.p_28_27_desviacion,
e.p_26_25_promedio,	
e.p_26_25_desviacion,
e.p_31_23_promedio,
e.p_31_23_desviacion,
e.p_32_24_promedio,
e.p_32_24_desviacion
from entrenamiento e 
inner join muestras m on e.muestraid =m.muestraid
inner join personas p on m.personaid =p.personaid


--delete from entrenamiento
--select * from entrenamiento


--consulta que devuelve el JSON

--select * from obtener_datos_entrenamiento()
CREATE OR REPLACE FUNCTION obtener_datos_entrenamiento()
RETURNS JSON AS $$
BEGIN
  RETURN (
   SELECT json_agg(
  json_build_object(
    'persona', persona,
    'muestra_id', muestra_id,
    'puntos', json_build_object(
      '26_25', json_build_object(
        'promedio', p_26_25_promedio,
        'desviacion', p_26_25_desviacion
      ),
      '28_27', json_build_object(
        'promedio', p_28_27_promedio,
        'desviacion', p_28_27_desviacion
      ),
      '31_23', json_build_object(
        'promedio', p_31_23_promedio,
        'desviacion', p_31_23_desviacion
      ),
      '32_24', json_build_object(
        'promedio', p_32_24_promedio,
        'desviacion', p_32_24_desviacion
      ),
      '32_31', json_build_object(
        'promedio', p_32_31_promedio,
        'desviacion', p_32_31_desviacion
      )
    )
  )
)
FROM (
  SELECT 
    ROW_NUMBER() OVER (ORDER BY e.videoid) AS muestra_id,
    p.persona,
    e.p_32_31_promedio,
    e.p_32_31_desviacion,
    e.p_28_27_promedio,
    e.p_28_27_desviacion,
    e.p_26_25_promedio,	
    e.p_26_25_desviacion,
    e.p_31_23_promedio,
    e.p_31_23_desviacion,
    e.p_32_24_promedio,
    e.p_32_24_desviacion
  FROM entrenamiento e 
  INNER JOIN muestras m ON e.muestraid = m.muestraid
  INNER JOIN personas p ON m.personaid = p.personaid
) sub
  );
END;
$$ LANGUAGE plpgsql;


--SELECT obtener_datos_entrenamiento()



--hacer tabla para guardar los modelos y poderlos listar
--drop table modelos
create table modelos(
	modeloid BIGSERIAL PRIMARY KEY,
	modelo text not null unique,
	modeloarchivo text not null default '',
	modeloentrenado bool not null default false,
	fecha timestamp default now() not null
);

--procedimiento para crear el modelo 
--call crearModelo('hola mundo 2')
CREATE OR REPLACE PROCEDURE public.crearModelo(
	in modelo_p text
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	insert into modelos(modelo) values (modelo_p);	
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;

--funcion para listar el modelo
--drop FUNCTION public.listarModelos()
CREATE OR REPLACE FUNCTION public.listarModelos()
 RETURNS TABLE(
  modeloid bigint, modelo text, fecha text, hora_minutos text, modeloarchivo text, modeloentrenado bool
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select m.modeloid,m.modelo,TO_CHAR(COALESCE(m.fecha, CURRENT_DATE), 'DD/MM/YYYY') ,
			 TO_CHAR(COALESCE(m.fecha, CURRENT_DATE), 'HH24:MI'), m.modeloarchivo,m.modeloentrenado from modelos m;
end;
$function$
;

--select * from listarModelos()
--select * from modelos


--procedimiento para eliminar el nombre de un modelo
CREATE OR REPLACE PROCEDURE public.eliminarModelo(
	in modeloid_p bigint
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	delete from modelos where  modeloid=modeloid_p;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;
--select * from modelos
--call editarModelo('hola mundo 22',2);
--procedimiento para editar el nombre de un modelo
CREATE OR REPLACE PROCEDURE public.editarModelo(
	in modelo_p text,
	in modeloid_p bigint
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	update modelos set modelo=modelo_p where modeloid=modeloid_p;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;


--crear modelo pero devolver el id para editarlo luego:
--select * from crearModeloID('heel')
CREATE OR REPLACE FUNCTION public.crearModeloID(modelo_p text)
 RETURNS TABLE(
  modeloid bigint
 )
 LANGUAGE plpgsql
AS $function$
begin

	--registrar el video 
	insert into modelos(modelo) values (modelo_p);	

	return query
	select m.modeloid from modelos m where m.modelo=modelo_p order by m.modeloid desc limit 1;

end;
$function$
;

--select * from modelos


--crear un procedimiento para editar el nombre del archivo del modelo y el estado por el id
CREATE OR REPLACE PROCEDURE public.editarModeloEntrenado(
	in modelo_p text,
	in modeloid_p bigint
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	update modelos set modeloarchivo=modelo_p,modeloentrenado=true where modeloid=modeloid_p;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;


--select * from modelos
--delete from modelos 

--select * from entrenamiento

--select * from muestras m 


-- hacer la funcion que retorne los id de las personas que tengan muestras que se entrenaran en el modelo creado

CREATE OR REPLACE FUNCTION public.listarMuestrasPersonas()
 RETURNS TABLE(
  personaid bigint, persona text, seleccionado bool, numero_muestras bigint
 )
 LANGUAGE plpgsql
AS $function$
begin
	return query
	select 
	p.personaid, p.persona , cast(false as bool) seleccionado, cast(COUNT(p.personaid) as bigint) as numero_muestras
	from muestras m inner join personas p on m.personaid =p.personaid
	group by  p.personaid order by p.persona;
end;
$function$
;


--select * from listarMuestrasPersonas()

---crear la tabla de personas-modelo 
--para poder registrar a las personas en el modelo creado

create table personas_modelo(
	modeloid bigint not null,
	personaid bigint not null,
	fecha timestamp default now() not null,
	CONSTRAINT fk_persona_modelo
        FOREIGN KEY (personaid)
        REFERENCES personas(personaid),
	CONSTRAINT fk_modelos_modelo
        FOREIGN KEY (modeloid)
        REFERENCES modelos(modeloid)
);

--crear un procedimineto que relacione las personas con el modelo seleccionado skere
CREATE OR REPLACE PROCEDURE public.relacionar_persona_modelo(
	in modeloid_p bigint, in personaid_p bigint
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	insert into personas_modelo(modeloid,personaid) values (modeloid_p,personaid_p);	
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;

--select * from personas_modelo
--select * from modelos




--modificar la funcion solo para enliste las personas que estan dentro del modelo
--obtener_datos_entrenamiento
--select * from obtener_datos_entrenamiento(24)
CREATE OR REPLACE FUNCTION obtener_datos_entrenamiento(modeloid_p bigint)
RETURNS JSON AS $$
BEGIN
  RETURN (

   SELECT json_agg(
  json_build_object(
    'persona', persona,
    'muestra_id', muestra_id,
    'puntos', json_build_object(
      '26_25', json_build_object(
        'promedio', p_26_25_promedio,
        'desviacion', p_26_25_desviacion
      ),
      '28_27', json_build_object(
        'promedio', p_28_27_promedio,
        'desviacion', p_28_27_desviacion
      ),
      '31_23', json_build_object(
        'promedio', p_31_23_promedio,
        'desviacion', p_31_23_desviacion
      ),
      '32_24', json_build_object(
        'promedio', p_32_24_promedio,
        'desviacion', p_32_24_desviacion
      ),
      '32_31', json_build_object(
        'promedio', p_32_31_promedio,
        'desviacion', p_32_31_desviacion
      )
    )
  )
)
FROM (
	select 
    ROW_NUMBER() OVER (ORDER BY e.videoid) AS muestra_id,
    p.persona,
    e.p_32_31_promedio,
    e.p_32_31_desviacion,
    e.p_28_27_promedio,
    e.p_28_27_desviacion,
    e.p_26_25_promedio,	
    e.p_26_25_desviacion,
    e.p_31_23_promedio,
    e.p_31_23_desviacion,
    e.p_32_24_promedio,
    e.p_32_24_desviacion	 
	from 
	personas_modelo pm
	INNER JOIN muestras m ON pm.personaid = m.personaid
	inner join entrenamiento e on e.muestraid = m.muestraid
	INNER JOIN personas p ON pm.personaid = p.personaid
	where pm.modeloid = modeloid_p
--select * from personas_modelo
) sub
  );
END;
$$ LANGUAGE plpgsql;


--select * from modelos order by modeloid

--select * from muestras
--select * from personas
--select * from entrenamiento where muestraid=11
--select * from personas_modelo

--ahora cuando se elimine un modelo hacer que tambien se eliminen los registros de personas_modelos
CREATE OR REPLACE PROCEDURE public.eliminarModelo(
	in modeloid_p bigint
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	delete from personas_modelo where modeloid=modeloid_p;
	delete from modelos where  modeloid=modeloid_p;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;


--ahora permitir eliminar las muestras de todas las tablas
CREATE OR REPLACE PROCEDURE public.eliminarMuestra(
	in muestraid_p bigint
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	delete from entrenamiento where muestraid=muestraid_p;
	delete from videos_muestras where muestraid=muestraid_p;
	delete from muestras where  muestraid=muestraid_p;
EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;

--select * from entrenamiento+
 

select * from obtener_datos_entrenamiento(13)


--select * from modelos


--agregar nuevos puntos a la tabla de entrenamiento
--select * from entrenamiento
alter table entrenamiento add p_16_12_promedio NUMERIC(20, 14) default 0 not null;
alter table entrenamiento add p_16_12_desviacion NUMERIC(20, 14) default 0 not null;
alter table entrenamiento add p_15_11_promedio NUMERIC(20, 14) default 0 not null;
alter table entrenamiento add p_15_11_desviacion NUMERIC(20, 14) default 0 not null;
alter table entrenamiento add p_32_16_promedio NUMERIC(20, 14) default 0 not null;
alter table entrenamiento add p_32_16_desviacion NUMERIC(20, 14) default 0 not null;
alter table entrenamiento add p_31_15_promedio NUMERIC(20, 14) default 0 not null;
alter table entrenamiento add p_31_15_desviacion NUMERIC(20, 14) default 0 not null;

--eliminar el procedimiento que guarda los puntos para crear uno nuevo que agrege los nuevos puntos

--drop procedure registrar_puntos_muestra(
	bigint,
	bigint,
	NUMERIC(20, 14),
	NUMERIC(20, 14),
	NUMERIC(20, 14),
	NUMERIC(20, 14),
	NUMERIC(20, 14),
	NUMERIC(20, 14),
	NUMERIC(20, 14),
	NUMERIC(20, 14),
	NUMERIC(20, 14),
	NUMERIC(20, 14)
	)

CREATE OR REPLACE PROCEDURE public.registrar_puntos_muestra(
	in videoid_p bigint,
	in muestraid_p bigint,
	in p_32_31_promedio_p   NUMERIC(20, 14),
	in p_32_31_desviacion_p NUMERIC(20, 14),
	in p_28_27_promedio_p   NUMERIC(20, 14),
	in p_28_27_desviacion_p NUMERIC(20, 14),
	in p_26_25_promedio_p   NUMERIC(20, 14),
	in p_26_25_desviacion_p NUMERIC(20, 14),
	in p_31_23_promedio_p   NUMERIC(20, 14),
	in p_31_23_desviacion_p NUMERIC(20, 14),
	in p_32_24_promedio_p   NUMERIC(20, 14),
	in p_32_24_desviacion_p NUMERIC(20, 14),
	in p_16_12_promedio_p   NUMERIC(20, 14),
	in p_16_12_desviacion_p NUMERIC(20, 14),
	in p_15_11_promedio_p   NUMERIC(20, 14),
	in p_15_11_desviacion_p NUMERIC(20, 14),
	in p_32_16_promedio_p   NUMERIC(20, 14),
	in p_32_16_desviacion_p NUMERIC(20, 14),
	in p_31_15_promedio_p   NUMERIC(20, 14),
	in p_31_15_desviacion_p NUMERIC(20, 14)
	)
 LANGUAGE plpgsql
AS $procedure$
Begin
	insert into entrenamiento(
		videoid,
		muestraid,
		p_32_31_promedio,
		p_32_31_desviacion,
		p_28_27_promedio,
		p_28_27_desviacion,
		p_26_25_promedio,
		p_26_25_desviacion,
		p_31_23_promedio,
		p_31_23_desviacion,
		p_32_24_promedio,
		p_32_24_desviacion,
		p_16_12_promedio,
		p_16_12_desviacion,
		p_15_11_promedio,
		p_15_11_desviacion,
		p_32_16_promedio,
		p_32_16_desviacion,
		p_31_15_promedio,
		p_31_15_desviacion
		)
	values (
		videoid_p,
		muestraid_p,
		p_32_31_promedio_p,
		p_32_31_desviacion_p,
		p_28_27_promedio_p,
		p_28_27_desviacion_p,
		p_26_25_promedio_p,
		p_26_25_desviacion_p,
		p_31_23_promedio_p,
		p_31_23_desviacion_p,
		p_32_24_promedio_p,
		p_32_24_desviacion_p,
		p_16_12_promedio_p,
		p_16_12_desviacion_p,
		p_15_11_promedio_p,
		p_15_11_desviacion_p,
		p_32_16_promedio_p,
		p_32_16_desviacion_p,
		p_31_15_promedio_p,
		p_31_15_desviacion_p
		);	

EXCEPTION
        -- Si ocurre un error en la transacción principal, revertir
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE EXCEPTION 'Error transaccional: %', SQLERRM;	
END;
$procedure$
;



--select * from obtener_datos_entrenamiento(14)
--select * from entrenamiento
--modificar la funcion que enlista las muestras que se seleccionar en un modelo al crearlo para entrenarlo solo con dichas muestras
CREATE OR REPLACE FUNCTION obtener_datos_entrenamiento(modeloid_p bigint)
RETURNS JSON AS $$
BEGIN
  RETURN (

   SELECT json_agg(
  json_build_object(
    'persona', persona,
    'muestra_id', muestra_id,
    'puntos', json_build_object(
      '26_25', json_build_object(
        'promedio', p_26_25_promedio,
        'desviacion', p_26_25_desviacion
      ),
      '28_27', json_build_object(
        'promedio', p_28_27_promedio,
        'desviacion', p_28_27_desviacion
      ),
      '31_23', json_build_object(
        'promedio', p_31_23_promedio,
        'desviacion', p_31_23_desviacion
      ),
      '32_24', json_build_object(
        'promedio', p_32_24_promedio,
        'desviacion', p_32_24_desviacion
      ),
      '32_31', json_build_object(
        'promedio', p_32_31_promedio,
        'desviacion', p_32_31_desviacion
      )
		,
      '16_12', json_build_object(
        'promedio', p_16_12_promedio,
        'desviacion', p_16_12_desviacion
      )
		,
      '15_11', json_build_object(
        'promedio', p_15_11_promedio,
        'desviacion', p_15_11_desviacion
      )
		,
      '32_16', json_build_object(
        'promedio', p_32_16_promedio,
        'desviacion', p_32_16_desviacion
      )
		,
      '31_15', json_build_object(
        'promedio', p_31_15_promedio,
        'desviacion', p_31_15_desviacion
      )
    )
  )
)
FROM (
	select 
    ROW_NUMBER() OVER (ORDER BY e.videoid) AS muestra_id,
    p.persona,
    e.p_32_31_promedio,
    e.p_32_31_desviacion,
    e.p_28_27_promedio,
    e.p_28_27_desviacion,
    e.p_26_25_promedio,	
    e.p_26_25_desviacion,
    e.p_31_23_promedio,
    e.p_31_23_desviacion,
    e.p_32_24_promedio,
    e.p_32_24_desviacion,
	e.p_16_12_promedio,
	e.p_16_12_desviacion,
	e.p_15_11_promedio,
	e.p_15_11_desviacion,
	e.p_32_16_promedio,
	e.p_32_16_desviacion,
	e.p_31_15_promedio,
	e.p_31_15_desviacion	 
	from 
	personas_modelo pm
	INNER JOIN muestras m ON pm.personaid = m.personaid
	inner join entrenamiento e on e.muestraid = m.muestraid
	INNER JOIN personas p ON pm.personaid = p.personaid
	where pm.modeloid = modeloid_p
--select * from personas_modelo
) sub
  );
END;
$$ LANGUAGE plpgsql;





