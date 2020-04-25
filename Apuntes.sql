------------------------------Ejemplo desarrollado para el curso Profesional de Base de Datos--------------------------
Drop Database If Exists libreria_natra;
Create Database If not Exists libreria_natra;

use libreria_natra;

Create table If not Exists autores (
		autor_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
		nombre VARCHAR(25) NOT NULL,
		apellido VARCHAR(25) NOT NULL,
		seudonimo VARCHAR(50) UNIQUE,
		genero ENUM('M', 'F'),
		fecha_nacimiento DATE NOT NULL,
		pais_origen VARCHAR(40) NOT NULL,
		fecha_creacion DATETIME Default current_timestamp
	);

	Create Table libros(
		libro_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
		autor_id INT UNSIGNED NOT NULL,
		titulo VARCHAR(50) NOT NULL,
		descripcion VARCHAR(250),
		paginas INTEGER UNSIGNED,
		fecha_publicacion Date NOT NULL,
		fecha_creacion DATETIME Default current_timestamp,
		FOREIGN KEY (autor_id) REFERENCES autores(autor_id)
	);
	Create table usuarios(
		usuario_id int UNSIGNED PRIMARY KEY AUTO_INCREMENT,
		nombre VARCHAR(25) NOT NULL,
		apellidos VARCHAR(25),
		username VARCHAR(25) NOT NULL,
		email VARCHAR(50) NOT NULL,
		fecha_creacion DATETIME Default current_timestamp
	);

insert into autores (nombre, apellido, genero, fecha_nacimiento, pais_origen)
values  ('Frank', 'Sinatra', 'M', '2016-09-30', 'Polombia'),
				('Fredsi', 'Mercury', 'M', '2018-09-02', 'Polombia'),
				('Jodin', 'Pinguin', 'M', '2016-10-02', 'Polombia'),
				('Eva', 'Maria', 'F', '2016-09-30', 'Polombia'),
				('Mara', 'Leta', 'F', '2016-09-30', 'Polombia'),
				('Dulce', 'Marie', 'F', '2016-09-30', 'Polombia');

insert into libros(autor_id, titulo, fecha_publicacion)
	values  (1, 'Carrie', '1974-01-01'),
					(2, 'Harry Potter y la piedra filosofal', '1997-06-30');

insert into usuarios (nombre, apellidos, username, email)
	values  ('Cesar', 'Ramirez', 'CesarRamF', 'cesarramirezfilomena@hotmail.com'),
					('Male', 'Romero', 'MaleRomB', 'misticaromero@hotmail.com');

Select * from autores;
Select * from libros;
SELECT * from usuarios;

SELECT * FROM libros WHERE titulo IN ('Carrie', 'Harry Potter y la priedra filosofal');
---------------------------------Funciones---------------------------
DELIMITER //

Create FUNCTION agregar_dias(fecha Date, dias INT)
RETURNS Date
Begin
  return fecha + interval dias Day;
End //

Create FUNCTION Obtener_ventas()
RETURNS int
Begin
  Set @paginas = (Select(Round(Rand()*100)*6));
  RETURN @paginas;
END //

DELIMITER ;
----------------------------------------------------------------------------------------
--------------------------------------------Otros Apuntes-------------------------------
----------------------------------------------------------------------------------------
DELIMITER //

create FUNCTION obtener_paginas()
  RETURNS int
  Begin
    Set @paginas= (SELECT (round(rand()*100)*4));
    return @paginas;
  End //

DELIMITER ;

Update libros SET paginas = obtener_paginas();
-------------------------Ejemplos------------------------------------
Select * FROM libros where titulo like 'Harry Potter%';--cuando frase esta al inicio % a la der, si es final % a la izq y si no se donde esta % en ambos lados

Select * from libros where titulo like '__b__'; --buscar una frase que contenga 5 caracteres y el tercero sea b

Select * from libros where titulo like '_a%';

Select * from libros where titulo like 'H%' or titulo like  'L%';
Select * from libros where left(titulo,1) = 'H' or left(titulo,1) = 'L';
----------------------Expresiones regulares-----------------------
Select titulo from libros where titulo REGEXP- '^[HL]'; -- Se obtiene el mismo resultado que arriba pero con mejor rendimiento

Select titulo FROM libros ORDER BY titulo ASC; -- Ordenar un resultado y DESC al final para que sea descendente el resultado o ASC (ascendente)

Select titulo from libros limit 10; --limitar los registros de resultados
Select titulo from libros where autor_id = 2 limit 10;
Select libro_id, titulo from libros limit 0, 5; -- El primer int es desde donde comienza, y el segundo int es cuantos necesito que se obtengan
---------------------- Funciones de agregacion -------------------
Select COUNT(*) from Autores; -- me permite contar la cantidad de registros
Select COUNT(*) AS total FROM autores where seudonimo is not null;

Select Sum(ventas) from libros; -- Sum permite sumar registros

Select MAX(ventas) from libros;
Select MIN(ventas) from libros;

Select AVG(ventas) from libros; -- Promedio
--------------------- Agrupamiento------------------------
SELECT autor_id, sum(ventas) as total FROM libros group by autor_id order by total desc limit 1;

SELECT autor_id, sum(ventas) as total FROM libros group by autor_id HAVING sum(ventas) > 100;
----------------------Unir resultados---------------------
Select CONCAT(nombre, ' ', apellido) AS nombre_Completo from autores
UNION
Select CONCAT(nombre, ' ', apellidos) from usuarios;
----------------------Sub consultas----------------------
SELECT AVG(ventas) FROM libros;
SELECT CONCAT (nombre, ' ', apellido) AS Nombre FROM autores where autor_id IN(
SELECT autor_id FROM libros GROUP BY autor_id HAVING sum(ventas) > (SELECT AVG(ventas) from libros));
------------------Validar registros-----------------------
SELECT IF(Exists(SELECT libro_id from libros where titulo ='Carrie'), 'Disponible', 'No Disponible' ) AS Disponible;
----------------------------------------------------------------
----------------------------Inner Join--------------------------
----------------------------------------------------------------
Select libros.titulo, CONCAT(autores.nombre, " ", autores.apellido) as Nombre_Autor, libros.fecha_creacion from libros
INNER JOIN autores ON libros.autor_id = autores.autor_id;---------Es mas recomendable

Select libros.titulo, CONCAT(autores.nombre, " ", autores.apellido) as Nombre_Autor, libros.fecha_creacion from libros
INNER JOIN autores USING autor_id; -----------Otra forma de hacerlo cuando las llaves foraneas tienen el mismo nombre

Select
      libros.titulo,
      CONCAT(autores.nombre, " ", autores.apellido) as Nombre_Autor,
      libros.fecha_creacion from libros
INNER JOIN autores  ON libros.autor_id = autores.autor_id
                    AND autores.seudonimo IS NOT NULL; ----- Condicionar un inner JOIN
--------------------------Left Join-----------------------
usuarios=a
libros_usuarios=b
SELECT
  CONCAT(nombre, ' ', apellidos),
  libros_usuarios.libro_id
  FROM usuarios
  LEFT JOIN libros_usuarios ON usuarios.usuario_id = libros_usuarios.usuario_id
  where libros_usuarios.libro_id is not null;
--------------------------Right Join---------------------
libros_usuarios = a
usuarios = b
SELECT
  CONCAT(nombre, ' ', apellidos),
  libros_usuarios.libro_id
  FROM libros_usuarios
  RIGHT JOIN usuarios ON usuarios.usuario_id = libros_usuarios.usuario_id
  where libros_usuarios.libro_id is not null;
  -------------------------Multiples Joins------------------
usuarios
libros_usuarios
libros
Autores
SELECT DISTINCT
  CONCAT(usuarios.nombre, ' ', usuarios.apellidos) AS nombre_usuario
FROM usuarios
INNER JOIN libros_usuarios ON usuarios.usuario_id = libros_usuarios.usuario_id
            AND DATE(libros_usuarios.fecha_creacion) = CURDATE()
INNER JOIN libros ON libros_usuarios.libro_id = libros.libro_id
INNER JOIN autores ON libros.autor_id = autores.autor_id
            AND autores.seudonimo IS NOT NULL;
-----------------------------Productos cartesianos-------------------
SELECT usuarios.username, libros.titulo from usuarios CROSS JOIN libros ORDER BY username desc;
-----------------------------Vistas--------------------------------
CREATE OR REPLACE VIEW prestamos_usuarios_vw AS
SELECT
  usuarios.usuario_id,
  usuarios.nombre,
  usuarios.email,
  usuarios.username,
  COUNT(usuarios.usuario_id) AS total_prestamos
FROM usuarios
INNER JOIN libros_usuarios ON usuarios.usuario_id = libros_usuarios.usuario_id
            AND libros_usuarios.fecha_creacion >= CURDATE() - interval 5 DAY
GROUP BY usuarios.usuario_id;
-------------------------------------------------------------------------------------
---------------------------------------Apuntes Procedures----------------------------
-------------------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE prestamo1(usuario_id INT,libro_id INT, OUT cantidad INT)
BEGIN
  INSERT INTO libros_usuarios(libro_id, usuario_id) VALUES (libro_id, usuario_id);
  UPDATE libros SET stock = stock - 1 where libros.libro_id = libro_id;
  SET cantidad = (SELECT stock FROM libros where libros.libro_id = libro_id)
END //
DELIMITER ;
--------------------------------------Apuntes------------------------------
select name from mysql.proc where db = database() AND type = 'PROCEDURE'; ---------Consultar los PROCEDURE
CALL prestamo(3,20); ------------Llamar a un PROCEDURE
DROP PROCEDURE; --------- Eliminar un PROCEDURE
---------------------------------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE prestamo1(usuario_id INT,libro_id INT, OUT cantidad IN)
BEGIN
  SET cantidad = (SELECT stock FROM libros where libros.libro_id = libro_id);

  IF cantidad > 0 THEN

    INSERT INTO libros_usuarios(libro_id, usuario_id) VALUES (libro_id, usuario_id);
    UPDATE libros SET stock = stock - 1 where libros.libro_id = libro_id;

    SET cantidad = cantidad - 1;

    ELSE ------ELSEIF condicion

    SELECT 'No es posible realizar el prestamo' AS mensaje_error;
  END IF;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE tipo_lector2(usuario_id INT)
BEGIN

  SET @cantidad = (SELECT COUNT(*) FROM libros_usuarios
                    WHERE libros_usuarios.usuario_id = usuario_id);
  CASE
    WHEN @cantidad > 20 THEN
      SELECT 'Fanatico' As mensaje;
    WHEN @cantidad > 10 AND @cantidad < 20 THEN
      SELECT 'Aficionado' As mensaje;
    WHEN @cantidad > 5 AND @cantidad < 10 THEN
      SELECT 'Promedio' As mensaje;
    ELSE
      SELECT 'Nuevo' As mensaje;
  END CASE;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE libros_azar1()
BEGIN
  SET @iteracion = 0;
  ---WHILE @iteracion < 5 DO
  REPEAT
    SELECT libro_id, titulo FROM libros ORDER BY RAND() LIMIT 1;
    SET @iteracion = @iteracion + 1;

    UNTIL @iteracion >= 5
  END REPEAT;
---  END WHILE;
END //
DELIMITER ;
----------------------------------------------------------------------
-----------------------------Apuntes Trigger--------------------------
----------------------------------------------------------------------
DELIMITER //
CREATE TRIGGER after_insert_actualizacion_libros
AFTER INSERT ON libros
FOR EACH ROW
BEGIN
  UPDATE autores SET cantidad_libros = cantidad_libros + 1 where autor_id = NEW.autor_id;
END;
//

CREATE TRIGGER after_delete_actualizacion_libros
AFTER DELETE ON libros
FOR EACH ROW
BEGIN
  UPDATE autores SET cantidad_libros = cantidad_libros - 1 where autor_id = OLD.autor_id;
END;
//

CREATE TRIGGER after_update_actualizacion_libros
AFTER UPDATE ON libros
FOR EACH ROW
BEGIN
  IF(new.autor_id != OLD.autor_id) THEN
    UPDATE autores SET cantidad_libros = cantidad_libros + 1 where autor_id = NEW.autor_id;
    UPDATE autores SET cantidad_libros = cantidad_libros - 1 where autor_id = OLD.autor_id;
    END IF;
END;
//
DELIMITER ;

SHOW TRIGGERS; ----- Listar TRIGGERS
DROP TIGGER IF EXISTS libreria_cf.after_delete_actualizacion_libros;
