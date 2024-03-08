<?php

// Função para carregar as variáveis do .env
function loadEnv(string $path='.', bool $advSecurity=true )
{
    $env = [];
    $file = fopen("$path/.env", 'r');
    while (($line = fgets($file)) !== false)
    {
        $line = trim($line);
        if (empty($line) || $line[0] === '#')
        {
            continue;
        }
        list($key, $value) = explode('=', $line, 2);
        if( $$advSecurity )
        {
            $value = trim($value, '"'); // Remove aspas duplas
            $value = stripcslashes($value); // Remove backslashes
        }
        $env[$key] = $value;
    }
    fclose($file);
    $GLOBALS['_ENV'] = $env;
}
loadEnv();
?>
