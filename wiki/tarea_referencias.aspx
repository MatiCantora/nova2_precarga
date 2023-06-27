<%@ Page Language="VB" AutoEventWireup="false" Inherits="nvFW.nvPages.nvPageWiki" %>
<html>
<head>
    <title>Referencia Tareas</title>
    <link href="/FW/css/base.css" type="text/css" rel="stylesheet" />
</head>
<body style="width:100%;height:100%;overflow:hidden;background:#FFFFFF;">
    <table class="tb1">
        <tr>
            <td colspan="5" style='font-weight:bold'>Estado:</td>
        </tr>
        <tr>
            <td style="color:blue">&nbsp;pendiente</td>
            <td style="color:blue">&nbsp;en ejecución</td>
            <td style="text-decoration:line-through">&nbsp;completa</td>
            <td>&nbsp;aplazada</td>
            <td style="color:red">&nbsp;vencida</td>
        </tr>  
        <tr>
            <td colspan="5" style='font-weight:bold'>Prioridad:</td>
        </tr>
        <tr>
            <td>&nbsp;&nbsp;<img title='Prioridad Alta' src='/wiki/image/icons/pri_alta.png' alt='Prioridad Alta' style='vertical-align:middle !Important'/>Alta</td>
            <td>&nbsp;&nbsp;<img title='Prioridad Normal' src='/wiki/image/icons/pri_normal.png' alt='Prioridad Normal' style='vertical-align:middle !Important' />Normal</td>
            <td colspan="3">&nbsp;&nbsp;<img title='Prioridad Baja' src='/wiki/image/icons/pri_baja.png' alt='Prioridad Baja' style='vertical-align:middle !Important'/>Baja</td>
        </tr>
        <tr>
            <td colspan="5" style='font-weight:bold'>Otros:</td>
        </tr>
        <tr>
            <td colspan="5">
                <table class="tb1">
                    <tr>
                        <td nowrap="nowrap">&nbsp;&nbsp;<img title='Tarea Periodica' alt='Tarea Periodica' src='/wiki/image/icons/periodicidad.png' style='vertical-align:middle !Important' />Tarea Periodica</td>
                        <td nowrap="nowrap">&nbsp;&nbsp;<img title='Tarea Origen Periodica' alt='Tarea Origen Periodica' src='/wiki/image/icons/periodicidad_origen.png' style='vertical-align:middle !Important' />Tarea Origen Periodica</td>
                    </tr>
                </table>  
            </td> 
        </tr>
    </table>
</body>
</html>
