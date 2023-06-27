let cssEstadisticasId = 'cssEstadisticas';
const cssEstadisticas = ".stats-menu { "
    + "border-style: outset; "
    + "width: fit-content; "
    + "padding: 0 7px; "
    + "} "

    + ".stats-menu > p { "
    + "font-family: 'Segoe UI', sans-serif; "
    + "font-size: 15px; "
    + "font-weight: bold; "
    + "padding-bottom: 5px; "
    + "border-bottom: 1px solid rgb(128, 128, 128); "
    + "width: fit-content; "
    + "} "

    + ".stats-menu > ul { "
    + "list-style-type: \"\"; "
    + "margin: 0; "
    + "padding: 5px 10px; "
    + "} "

    + ".stats-menu > ul > li { "
    + "font-family: 'Segoe UI', sans-serif; "
    + "font-size: 15px; "
    + "font-style: italic; "
    + "line-height: 1.75em; "
    + "} "

    + ".more-stats-item { "
    + "transition: all 0.1s linear; "
    + "} "

    + ".more-stats-item:hover { "
    + "cursor: pointer; "
    + "background-color: rgba(0, 0, 0, 0.08); "
    + "} "

    + "#stats-chart { "
    + "visibility: hidden !important; "
    + "} "
if (!document.getElementById(cssEstadisticasId)) {
    let head = document.getElementsByTagName('head')[0];
    let style = document.createElement('style');
    style.id = cssEstadisticasId;
    style.type = 'text/css';
    head.appendChild(style);

    if (style.styleSheet) {
        // This is required for IE8 and below.
        style.styleSheet.cssText = cssEstadisticas;
    } else {
        style.appendChild(document.createTextNode(cssEstadisticas));
    }
}


const STAT_QUERY_NAMES = ["Consultas", "Aprobados", "Manual", "Rechazados"];
let estadisticas = [];

// ================ START - ESTADISTICAS ================ //
function openModalWithQueryOrCredit(type) {

    if (!nvFW.tienePermiso('permisos_precarga', 16)) {
        nvFW.alert('No posee permisos para ver las estadisticas de consultas.')
        return
    }

    let win_queriesModal = createWindow2({
        url: '/precarga/estadisticas/verEstadisticas.aspx?type=' + type,
        title: '<b>Estadisticas mensuales de ' + type + '</b>',
        //centerHFromElement: $("contenedor"),
        //parentWidthElement: $("contenedor"),
        //parentWidthPercent: 0.9,
        //parentHeightElement: $("contenedor"),
        //parentHeightPercent: 0.9,
        maxHeight: 500,
        maxWidth: (type == "Consultas") ? 950 : 1200,
        minimizable: false,
        maximizable: false,
        draggable: true,
        resizable: true//,
        //onClose: win_queriesModal.close()
    });

    win_queriesModal.options.userData = { res: '' };
    win_queriesModal.showCenter(true);

    // Sera necesario?
    if (isMobile()) {
        mostrarMenuIzquierdo();
    }
}

function cargarValoresEstadisticas() {

    let rs = new tRS();
    rs.async = true;
    rs.onComplete = function (rs) {

        if (!rs.eof()) {

            // [total, aprobados, manual, rechazados, cred_liq, cred_gestion]

            estadisticas.push(rs.getdata('total'));
            estadisticas.push(rs.getdata('aprobados'));
            estadisticas.push(rs.getdata('manual'));
            estadisticas.push(rs.getdata('rechazados'));
            //estadisticas.push(rs.getdata('cred_total'));
            estadisticas.push(rs.getdata('cred_liq'));
            estadisticas.push(rs.getdata('cred_gestion'));

            mostrarEstadisticas();

            // Si mas adelante se necesita, va a haber un grafico circular dinamico habilitando esta funcion
            //crearGraficoEstadisticas();
        }
    }

    rs.onError = function (rs) {

    }

    rs.open({
        filtroXML: nvFW.pageContents.verStatsPrecarga,
        params: "<criterio><params nro_operador='" + operador.nro_operador + "' /></criterio>" // operador de prueba: 12872
        //params: "<criterio><params nro_operador='" + 132 + "' /></criterio>" // operador de prueba: 12872
    });
}

function mostrarEstadisticas() {

    /*
     Diseño del Menu de estadisticas
     
     Menu (containerMenu)
        -> container de estadisticas (containerStats)

            -> container que tiene la info de las consultas y de los creditos (containerInfo)
                -> 4 items (consultas totales, aprobados, manuales, rechazados)
                -> 2 items (creditos totales, liquidados)
    */

    // ================= CREATIONS ================= //
    const containerMenu = document.getElementById("vMenuLeft.menuMobile");

    const containerStats = document.createElement("div");
    containerStats.setAttribute("class", "stats-menu");

    const containerGraph = document.createElement("div");

    const containerInfo = document.createElement("ul");

    const statsTitle = document.createElement("p");
    statsTitle.textContent = "Estadísticas mensuales";

    const STAT_CREDIT_NAMES = ["Créditos", "Liquidados", "En gestión"];
    const STAT_ITEM_COLOR = ["#000", "#038a0c", "#c97206", "#d40202"];

    const fragmentInfo = document.createDocumentFragment();

    const chartSVG = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    chartSVG.setAttribute("id", "stats-chart");

    // ================= SETS ================= //
    for (let i = 0; i < STAT_QUERY_NAMES.length; i++) {

        const liItem = document.createElement("li");

        liItem.textContent = STAT_QUERY_NAMES[i] + ": " + estadisticas[i];
        liItem.style.color = STAT_ITEM_COLOR[i];

        if (i === 0) {
            liItem.addEventListener("click", () => openModalWithQueryOrCredit("Consultas"));
            liItem.classList.add("more-stats-item");
        }

        fragmentInfo.appendChild(liItem);
    }

    fragmentInfo.appendChild(document.createElement('br'));

    for (let i = 0; i < STAT_CREDIT_NAMES.length; i++) {

        const liItem = document.createElement("li");

        if (i == 0) {
            liItem.textContent = STAT_CREDIT_NAMES[i];
        }
        else {
            liItem.classList.add("more-stats-item");

            liItem.textContent = STAT_CREDIT_NAMES[i] + ": " + estadisticas[3 + i];

            liItem.addEventListener("click", () => openModalWithQueryOrCredit(i == 1 ? "Liquidados" : "Gestion"));

            /*
            if (i === 1) {
                liItem.addEventListener("click", () => openModalWithQueryOrCredit("Liquidados"));
            }
            else {
                liItem.addEventListener("click", () => openModalWithQueryOrCredit("Gestion"));
            }
            */
        }

        liItem.style.color = STAT_ITEM_COLOR[i];

        fragmentInfo.appendChild(liItem);
    }

    // ================= APPENDS ================= //
    containerStats.appendChild(statsTitle);

    containerInfo.appendChild(fragmentInfo);
    containerStats.appendChild(containerInfo);

    //containerGraph.appendChild(chartSVG);

    containerMenu.appendChild(containerStats);
    containerMenu.appendChild(document.createElement("br"))
    //containerMenu.appendChild(containerGraph);            
}

function crearGraficoEstadisticas() {

    let actualPortions = calculateGraphPortions();

    // Por el momento esta hecho para la primera parte (consultas, no creditos)
    let chartProperties = {

        id: "stats-chart",
        radius: 85,
        segments: [
            { value: actualPortions["Aprobados"], color: "#038a0c" }, // aprobados
            { value: actualPortions["Manual"], color: "#fcca26" }, // manual
            { value: actualPortions["Rechazados"], color: "#d40202" }  // rechazados
        ]
    };

    drawChart(chartProperties);
}

function calculateGraphPortions() {

    let auxStats = [...estadisticas];
    const portions = {};

    // Son 3 porque son Aprobados, Manual y Rechazados.
    for (let i = 1; i <= 3; i++) {

        portions[STAT_QUERY_NAMES[i]] = auxStats[i];
    }

    const pairPortions = Object.entries(portions);

    pairPortions.sort((a, b) => a[1] - b[1]);

    for (let i = 0; i < 3; i++) {

        portions[pairPortions[i][0]] = i + 1;
    }

    return portions;
}

function drawChart(chartProperties) {

    const chartID = document.getElementById('stats-chart');

    // Set size of <svg> element
    chartID.setAttribute("width", 2 * chartProperties.radius);
    chartID.setAttribute("height", 2 * chartProperties.radius);

    // Calculate sum of values
    let sum = 0;
    let radius = chartProperties.radius;

    for (let e = 0; e < chartProperties.segments.length; e++) {
        sum += chartProperties.segments[e].value;
    }

    // Generate proportional pie for all segments
    let startAngle = 0, endAngle = 0;

    for (let i = 0; i < chartProperties.segments.length; i++) {

        let element = chartProperties.segments[i];
        let angle = element.value * 2 * Math.PI / sum;

        endAngle += angle;

        let svgLine = makeSVG('line', {
            x1: radius,
            y1: radius,
            x2: (Math.cos(endAngle) * radius + radius),
            y2: (Math.sin(endAngle) * radius + radius),
            stroke: element.color
        });

        chartID.append(svgLine);

        let pathStr =
            "M " + (radius) + "," + (radius) + " " +
            "L " + (Math.cos(startAngle) * radius + radius) + "," + (Math.sin(startAngle) * radius + radius) + " " +
            "A " + (radius) + "," + (radius) + " 0 " + (angle < Math.PI ? "0" : "1") + " 1 " + (Math.cos(endAngle) * radius + radius) + "," + (Math.sin(endAngle) * radius + radius) + " " +
            "Z";

        var svgPath = makeSVG('path', {
            d: pathStr,
            fill: element.color
        });

        chartID.append(svgPath);

        startAngle += angle;
    }
}

function makeSVG(tag, attrs) {

    let el = document.createElementNS("http://www.w3.org/2000/svg", tag);

    for (var k in attrs) {
        el.setAttribute(k, attrs[k]);
    }

    return el;
}
        // ================ END - ESTADISTICAS ================ //