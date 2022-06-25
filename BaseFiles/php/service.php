<?php

/*
 * Authenty AE - Bom Princípio-RS  |  github.com/authentyAE
 * by: will.i.am                   |  github.com/williampilger
 *
 * 2022.02.23 - Bom Princípio - RS
 * ♪ - / -
 *  
 * Serviço responsável por ... .
 * 
 */

require_once __DIR__.'/_local/config.php';

if(log_operacoes) $microtimeStart = microtime(true);
$status = 500;
try
{

    $result = ['status'=>0];

    //Seu código aqui

    if(log_operacoes)
    {
        $microtimeTotal = microtime(true) - $microtimeStart;
        logInterno(11, "[$microtimeTotal s] ".__FILE__."( ) -> status='".$status."'");
    }
}
catch(Exception $e)
{
    $status = 506; // Erro/Conflito interno
    logInterno(6, 'Exception ocorreu em \''.__FILE__.'\' e=\''.$e->__toString().'\'.');
}

if(isset($result)){
    echo json_encode($result);
}

http_response_code($status);

?>
