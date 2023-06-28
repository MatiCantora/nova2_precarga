//CARGA DE CSS
let cssIdStep = 'cssSteps';
if (!document.getElementById(cssIdStep)) {
    let head = document.getElementsByTagName('head')[0];
    let link = document.createElement('link');
    link.id = cssIdStep;
    link.rel = 'stylesheet';
    link.type = 'text/css';
    link.href = '/precarga/css/steps.css';
    link.media = 'all';
    head.appendChild(link);
}

var currentStep = 0;
var totalSteps = 0; //deberia ser definicion del motor
var stepsArray = {};
var subtitleArray = [];

//Definir cada elemento

function wizzard() {

    currentStep = 0;
    totalSteps = 0;
    stepsArray = {};
    subtitleArray = [];
    $('divWizzard').innerHTML = '';

    stepsArray[0] = {}
    stepsArray[0].element = 'tbBuscar';//primer paso
    stepsArray[0].leyenda = 'Ingresa un DNI para iniciar búsqueda.';
    stepsArray[1] = {}
    stepsArray[1].element = 'divTrabajos';//segundo paso
    stepsArray[1].leyenda = 'Necesitamos conocer el empleador.';//segundo paso
    stepsArray[2] = {}
    stepsArray[2].element = 'divSelCobro';//tercer paso
    stepsArray[2].leyenda = 'Seleccione un canal de cobro.';//tercer paso
    stepsArray[3] = {}
    stepsArray[3].element = 'divOfertaContenedor';//cuarto paso
    stepsArray[3].leyenda = 'Aquí está la mejor propuesta para tu cliente.';//tercer paso
    stepsArray[4] = {}
    stepsArray[4].element = 'divCreditoAlta';//quinto paso
    stepsArray[4].leyenda = 'Completar o modificar los datos para que la validación sea exitosa.';//quinto paso
    //stepsArray[4] = {}
    //stepsArray[4].element = 'divDatosPersonales';//tercer paso
    //stepsArray[4].leyenda = 'Aquí está la mejor propuesta para tu cliente.';//tercer paso

    for (let i in stepsArray) {
        totalSteps++;

        let divStep = document.createElement("div");
        divStep.id = 'divSteps' + i;
        divStep.className = 'step';
        let divInnerStep = document.createElement("div");
        divInnerStep.className = 'step-inner';
        divInnerStep.innerHTML = Number(i) + 1;

        divStep.appendChild(divInnerStep);
        $('divWizzard').appendChild(divStep);
    }

    showStep();
}

function showStep() {
    // Oculta todos los pasos    
    for (let i in stepsArray) {
        document.getElementById(stepsArray[i].element).hide();
        $('divSteps' + i).className = 'step';
    }

    // Muestra el paso actual
    document.getElementById(stepsArray[currentStep].element).show();
    $('wizzardLeyenda').innerHTML = stepsArray[currentStep].leyenda;
    $('divSteps' + currentStep).className = 'step active';

    //if (currentStep == 2) {
    //    stepsArray[currentStep] = 'block'
    //    stepsArray[currentStep + 1] = 'block'

    //}
}

function goToNextStep() {
    if (currentStep < totalSteps) {
        currentStep++;
        showStep(currentStep);
    }
}
// Agregar el evento click al los elementos que tengan la clase nextButton"
//var nextButtons = document.getElementsByClassName('nextButton');
//nextButtons = Array.from(nextButtons);
//nextButtons = nextButtons.map((button) => button.addEventListener('click', goToNextStep));
