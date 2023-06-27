using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualBasic;
using nvFW;

partial class prueba_nvFW_cs : nvFW.nvPages.nvPageAdmin
{

    protected override void Page_Load(object sender, System.EventArgs e)
    {
        base.Page_Load(sender, e);

        this.contents["dato1"] = "Hola mundo";
        this.contents["dato2"] = DateTime.Now;
        this.contents["dato3"] = 15;
        this.contents["dato4"] = (double)(15);
        this.contents["dato5"] = (double)(15.35);

        this.contents["filtroXML_exportar_ej1"] = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='estado'><campos>*</campos><filtro></filtro></select></criterio>");
        //this.contents["filtroXML_exportar_ej1"] = nvFW.nvXMLSQL.encXMLSQL("<criterio><select vista='operadores'><campos>*</campos><filtro><operador>" + this.operador.operador + "</operador></filtro></select></criterio>");
    }
}
