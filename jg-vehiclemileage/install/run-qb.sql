-- Primero verifica si la columna ya existe
SET @dbname = DATABASE();
SET @tablename = 'player_vehicles';
SET @columnname = 'mileage';
SET @preparedStatement = (SELECT IF(
  EXISTS(
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ),
  'SELECT 1', -- Si existe, no hacemos nada
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' FLOAT DEFAULT 0 NOT NULL;')
));

PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;