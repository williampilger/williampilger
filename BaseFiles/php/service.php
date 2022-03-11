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

try
{
    require_once __DIR__.'/local/sql_tools.php';

    $result = Array('status'=>0);

    //Seu código aqui

    if(log_operacoes)
    {
        $microtimeTotal = microtime(true) - $microtimeStart;
        logInterno('PHP_WS', "[$microtimeTotal s] ".__FILE__."(_GET='$_GET') -> status='".$result['status']."'");
    }
}
catch(Exception $e)
{
    logInterno('EXCEPTION', 'Exception ocorreu em \''.__FILE__.'\' e=\''.$e->__toString().'\'.');
    $result = array('status'=>20,'mensagem'=>'Erro AD2202231042.');
}

echo json_encode($result);

?>
