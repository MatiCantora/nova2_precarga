//using nvFW;
//using nvFW.nvTransferencia;

//namespace MyDinamic
//{
//    class SSR_Execute
//    {
//        public nvFW.nvTransferencia.tTransfererncia Transf;
//        public nvFW.nvTransferencia.tTransfDet Det;
//        public System.Int32 numero
//        {
//            get { return (System.Int32)Transf.param["numero"]["valor"]; }
//            set { Transf.param["numero"]["valor"] = value; }
//        }
//        public System.String cod_sistema
//        {
//            get { return (System.String)Transf.param["cod_sistema"]["valor"]; }
//            set { Transf.param["cod_sistema"]["valor"] = value; }
//        }


//        public void ejecutar()
//        {
//            numero = 25;
//            nvFW.tnvApp nvApp = nvFW.nvApp.get_getInstance();
//            cod_sistema = nvApp.cod_sistema;
//        }
//    }
//}