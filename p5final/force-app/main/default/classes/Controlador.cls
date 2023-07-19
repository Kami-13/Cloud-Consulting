public without sharing class Controlador {
	@AuraEnabled(cacheable=True)
    public static ResourceAllocationService.Proyecto_Recursos_Clase getRecursos(Id proId) {
        ResourceAllocationService servicio = new ResourceAllocationService();
        return servicio.obtener_Proyecto_Recursos_Clase(proId);
    }
    
    @AuraEnabled
    public static Boolean setRecursos(String strJSON){
        return ResourceAllocationService.registrar_Recursos(strJSON);
    }
    
    @AuraEnabled(cacheable=True)
    public static TaskAssignationService.Proyecto_Recursos_Tareas getTareas(Id proId) {
        TaskAssignationService servicio = new TaskAssignationService();
        return servicio.obtener_Proyecto_Recursos_Tarea(proId);
    }
    
    @AuraEnabled
    public static Boolean setTareas(String strJSON){
        return TaskAssignationService.registrar_Tareas(strJSON);
    }
    
    @AuraEnabled(cacheable=True)
    public static TareasSevice.Tareas getTareasHoras() {
        TareasSevice servicio = new TareasSevice();
        return servicio.obtener_Tareas();
    }
    
    @AuraEnabled
    public static Boolean setTareasHoras(String strJSON){
        return TareasSevice.registrar_Horas(strJSON);
    }
    
    @AuraEnabled
    public static Boolean setTareasEstado(String strJSON){
        return TareasSevice.actualizar_estado(strJSON);
    }
    
}