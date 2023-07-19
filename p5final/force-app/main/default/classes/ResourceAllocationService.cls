public with sharing class ResourceAllocationService {

    
    public static Boolean registrar_Recursos(String strJSON){        
        
         List<Project_Resource__c> recursos_proyecto_ListaJSON = (List<Project_Resource__c>)JSON.deserialize(strJSON, List<Project_Resource__c>.class);
         insert recursos_proyecto_ListaJSON;
         return true;
    }
    
    
    public class Proyecto_Recursos_Clase {
        
//==================================================================== Atributos ====================================================================
        @AuraEnabled
        public Map<String, List<User>> roles_usuarios_map;
        @AuraEnabled
        public Project__c proyecto;
        @AuraEnabled
        public Map<Id, List<Project_Resource__c>> usuarios_id_fechas_map;
        @AuraEnabled
        public Map<String, Integer> roles_horas_asignadas_proyecto;
        
//==================================================================== Constructor ===================================================================
        public Proyecto_Recursos_Clase(Project__c proyecto, Map<String, List<User>> roles_usuarios_map, 
                                       Map<Id, List<Project_Resource__c>> usuarios_id_fechas_map, 
                                       Map<String, Integer> roles_horas_asignadas_proyecto){
            this.proyecto = proyecto;
            this.roles_usuarios_map = roles_usuarios_map;
            this.usuarios_id_fechas_map = usuarios_id_fechas_map;
            this.roles_horas_asignadas_proyecto = roles_horas_asignadas_proyecto;
        }        
    }
    
//==================================================================== Funciones ====================================================================

    public proyecto_Recursos_Clase obtener_Proyecto_Recursos_Clase(Id proId){
        
             Project__c pro = [SELECT Date_Start__c, Date_End__c, Status__c,
                                      (SELECT Role__c, Quantity_Of_Hours__c  
                                       FROM Project_Roles__r) 
                               FROM Project__c WHERE Id=:proId];
             
             List<Project_Resource__c> p_recursos1_lista = [SELECT Resource__c 
                                                            FROM Project_Resource__c 
                                                            WHERE (Date_Start__c <= :pro.Date_Start__c 
                                                                   AND 
                                                                   Date_End__c >= :pro.Date_End__c)];
             //List<Project_Resource__c> p_recursos2_lista = [SELECT Resource__c 
                                                            //FROM Project_Resource__c
                                                            //WHERE Project__r.Id = :pro.Id];
             //WHERE Project_Role__r.Project__r.Id = :pro.Id
             //List<Project_Resource__c> p_recursos3_lista = new List<Project_Resource__c>();
                                       //p_recursos3_lista.addAll(p_recursos1_lista);
                                       //p_recursos3_lista.addAll(p_recursos2_lista);
             Set<Id> user_Id_set = new Set<Id>();
            //almaceno todos los usuarios que no pueden trabajar en el proyecto
             for(Project_Resource__c p_r: p_recursos1_lista){
                    user_Id_set.add(p_r.Resource__c);   
             }
             //mapa de roles por usuario
             Map<String, List<User>> roles_usuarios_map = new Map<String, List<User>>();
        	 List<User> usuarios_lista_totales = new List<User>();
             for(Project_Role__c p_role: pro.Project_Roles__r){
                 List<User> usuarios_rol_lista = [SELECT Id, Name, Rate_Hourly__c, UserRole.Name
                                                  FROM User
                                                  WHERE UserRole.Name = :p_role.Role__c AND Id NOT IN: user_Id_set];
                 roles_usuarios_map.put(p_role.Role__c, usuarios_rol_lista);
                 usuarios_lista_totales.addAll(usuarios_rol_lista);
             }
             //////////////////////////
             Map<Id,User> usuarios_rol_lista_mapa = new Map<Id,User>(usuarios_lista_totales);
        	 Set<id> usuarios_id_lista = new Set<Id>(usuarios_rol_lista_mapa.keySet());
        	 List<User> recursos_Completos_Lista = [SELECT (SELECT Date_Start__c, Date_End__c, Project__c
                                                            FROM Project_Resources__r
                                                            WHERE (NOT((Date_Start__c < :pro.Date_Start__c 
                                                                        AND 
                                                                        Date_End__c < :pro.Date_Start__c) 
                                                                       OR 
                                                                        (Date_Start__c > :pro.Date_End__c 
                                                                         AND Date_End__c > :pro.Date_End__c))))
                                                    FROM User
                                                    WHERE Id IN :usuarios_id_lista];
        	 Map<Id, List<Project_Resource__c>> usuarios_id_fechas_map = new Map<Id, List<Project_Resource__c>>();
             for(User r: recursos_Completos_Lista){
             	 usuarios_id_fechas_map.put(r.Id, r.Project_Resources__r);   
             }
             /////////////////////////
        	 
        	 /////////////////////////
        	 List<Project_Resource__c> project_resource_asignados = [SELECT Resource__c, Resource__r.UserRole.Name, 
                                                                            Project__c, Hours_Assigned_Resource__c  
                                                                     FROM Project_Resource__c
                                                                     WHERE Project__c = :proId];
        	 
        	 Map<String, Integer> roles_horas_asignadas_proyecto = new Map<String, Integer>();
        	 if(!project_resource_asignados.isEmpty()){
                 for(Project_Resource__c r: project_resource_asignados){
                     if(roles_horas_asignadas_proyecto.containsKey(r.Resource__r.UserRole.Name)){
                        Integer s = roles_horas_asignadas_proyecto.get(r.Resource__r.UserRole.Name);
                        roles_horas_asignadas_proyecto.put(r.Resource__r.UserRole.Name, r.Hours_Assigned_Resource__c.intValue() + s);
                     }else{
                        roles_horas_asignadas_proyecto.put(r.Resource__r.UserRole.Name, r.Hours_Assigned_Resource__c.intValue());
                     }
                 }
                 
                 for(Project_Role__c pr: pro.Project_Roles__r){
                    
                    if(!roles_horas_asignadas_proyecto.containsKey(pr.Role__c)){
                    	roles_horas_asignadas_proyecto.put(pr.Role__c, 0);    
                    }    
                 }
                 
             }else{
                 for(Project_Role__c pr: pro.Project_Roles__r){
                 	roles_horas_asignadas_proyecto.put(pr.Role__c, 0);    
                 } 
             }
        	 /////////////////////////
        
             //========================== Instanciando la Clase ==========================
             Proyecto_Recursos_Clase instanciada = new Proyecto_Recursos_Clase(pro, roles_usuarios_map, usuarios_id_fechas_map, roles_horas_asignadas_proyecto);
            
             return instanciada;
        }
}



























    /*
    public class Proyecto_Recursos_No_Registrados {
        
//==================================================================== Atributos ====================================================================
        @AuraEnabled
        public List<Project_Resource__c> recursos_No_Insertados;
        @AuraEnabled
        public Integer numero_recursos_No_Insertados;
//==================================================================== Constructor ===================================================================
        public Proyecto_Recursos_No_Registrados(Integer numero_recursos_No_Insertados, List<Project_Resource__c> recursos_No_Insertados){
            this.recursos_No_Insertados = recursos_No_Insertados;
            this.numero_recursos_No_Insertados = numero_recursos_No_Insertados;
        }        
    }
    */











 /*
            //Que no se salga del alcance de fechas del proyecto
            Project__c pro = [SELECT Date_Start__c, Date_End__c, 
                                     (SELECT Role__c, Quantity_Of_Hours__c  
                                      FROM Project_Roles__r) 
                              FROM Project__c WHERE Id=:proId];
             
            List<Project_Resource__c> p_recursos1_lista = [SELECT Resource__c 
                                                           FROM Project_Resource__c 
                                                           WHERE (Date_Start__c <= :pro.Date_Start__c 
                                                                  AND 
                                                                  Date_End__c >= :pro.Date_End__c)];
            List<Project_Resource__c> p_recursos2_lista = [SELECT Resource__c 
                                                            FROM Project_Resource__c
                                                            WHERE Project_Role__r.Project__r.Id = :pro.Id];
            List<Project_Resource__c> p_recursos3_lista = new List<Project_Resource__c>();
                                       p_recursos3_lista.addAll(p_recursos1_lista);
                                       p_recursos3_lista.addAll(p_recursos2_lista);
            Set<Id> user_Id_set = new Set<Id>();
            
            for(Project_Resource__c p_r: p_recursos3_lista){
                user_Id_set.add(p_r.Resource__c);   
            }
             
            Set<Id> usuarios_disponibles = new Set<Id>();
            Set<Id> usuarios_no_registrados = new Set<Id>();
            Set<Id> usuarios_fronted = new Set<Id>();
            
            for(Map<String, Object> obj: recursos_mapa){
                usuarios_fronted.add((Id)obj.get('Id'));
            }

            Integer valores_no_insertar = 0;
            Map<String, List<User>> usuarios_no_registrados_mapa = new Map<String, List<User>>();
            for (Id id_u: user_Id_set) {
                if (usuarios_fronted.contains(id_u)) {
                    valores_no_insertar++;
                    usuarios_no_registrados.add(id_u);
                    String error_mensaje = 'El usuario no esta disponible para este proyecto'; 
                    usuarios_no_registrados_mapa.put(error_mensaje, usuarios_no_registrados);
                }else{
                    usuarios_disponibles.add(id_u);
                }
            }
            */
            
            /*
            List<Map<String, Object>> recursos_mapa = (List<Map<String, Object>>)JSON.deserializeStrict(recursos_mapa_string, List<Map<String, Object>>.class);
            Map<String, List<User>> usuarios_no_registrados_mapa = new Map<String, List<User>>();
            Integer numero_recursos_no_insertados = 0;
            Project__c pro = [SELECT Date_Start__c, Date_End__c, 
                              (SELECT Quantity_Of_Hours__c
                               FROM Project_Roles__r)
                              FROM Project__c
                              WHERE Id = :proId];   
            List<Id> id_recursos_lista = new List<Id>();
            for(Map<String,Object> recurso: recursos_mapa){
                id_recursos_lista.add((Id)recurso.get('Id'));
            }
            
            List<User> recursos_lista = [SELECT (SELECT Date_Start__c, Date_End__c
                                                 FROM Project_Resources__r
                                                 WHERE Date_End__c < :pro.Date_End__c
                                                 ORDER BY Date_End__c DESC) 
                                         FROM USER
                                         WHERE Id IN : id_recursos_lista];
            List<Project_Resource__c> proyecto_recursos_lista = new List<Project_Resource__c>();
            Map<Id,User> recursos_lista_mapa = new Map<Id,User>(recursos_lista);
            for(Map<String,Object> mapa_recurso:recursos_mapa){
                if(recursos_lista_mapa.get((Id)mapa_recurso.get('Id')).Project_Resources__r.size() == 0){
                    Project_Resource__c proyecto_recurso = new Project_Resource__c();
                    proyecto_recurso.Project__c = proId;
                    proyecto_recurso.Resource__c = (Id)mapa_recurso.get('Id');
                    proyecto_recurso.Date_Start__c = Date.ValueOf((String.ValueOf(mapa_recurso.get('#######'))));
                    proyecto_recurso.Date_End__c = Date.ValueOf((String.ValueOf(mapa_recurso.get('#######'))));
                    proyecto_recursos_lista.add(proyecto_recurso);
                }else if(recursos_lista_mapa.get((Id)mapa_recurso.get('Id')).Project_Resources__r[0].Date_End__c < Date.ValueOf((String.ValueOf(mapa_recurso.get('#######'))))){
                    Project_Resource__c proyecto_recurso = new Project_Resource__c();
                    proyecto_recurso.Project__c = proId;
                    proyecto_recurso.Resource__c = (Id)mapa_recurso.get('Id');
                    proyecto_recurso.Date_Start__c = Date.ValueOf((String.ValueOf(mapa_recurso.get('#######'))));
                    proyecto_recurso.Date_End__c = Date.ValueOf((String.ValueOf(mapa_recurso.get('#######'))));
                    proyecto_recursos_lista.add(proyecto_recurso);
                }else {
                    List<User> usuario_no_registrado = [SELECT Name
                                                        FROM User
                                                        WHERE Id = :(Id)mapa_recurso.get('Id')];
                    //if(!usuario_no_registrado.isEmpty()){
                        usuarios_no_registrados_mapa.put('1', usuario_no_registrado);
                        numero_recursos_no_insertados++;
                    //}
                }
            }
            
            if(!proyecto_recursos_lista.isEmpty()){
                insert proyecto_recursos_lista;
            }
        
            Proyecto_Recursos_No_Registrados instanciada = new Proyecto_Recursos_No_Registrados(numero_recursos_no_insertados, usuarios_no_registrados_mapa);   
        
            return instanciada;
            
            */
            
        	//Boolean i = true;
        
        	//System.debug('El JSON recibido: ' + strJSON);























	
        	//VariablesEstructuras.set_trigger_Finalizo(False);
        	//VariablesEstructuras.clear_recursos_No_Insertados();
        	//System.debug('Despues de la Insercion: ' + recursos_proyecto_ListaJSON);
        	
        	/*
        	if(recursos_proyecto_ListaJSON.isEmpty()){
        			i = false;    
        	}
 			*/
        
//=================================== Descomentar Validaciones ========================================        
        /*
        	Id proId = recursos_proyecto_ListaJSON[0].Project__c;
        	
        	
            List<Map<String,Object>> recursos_mapa = new List<Map<String,Object>>();
            for(Project_Resource__c pr: recursos_proyecto_ListaJSON){
                Map<String,Object> mapa_str_object = pr.getPopulatedFieldsAsMap();
                recursos_mapa.add(mapa_str_object);               
            }
        
            Map<String, List<User>> usuarios_no_registrados_mapa = new Map<String, List<User>>();
            Integer numero_recursos_no_insertados = 0;
            Project__c pro = [SELECT Date_Start__c, Date_End__c, 
                              (SELECT Quantity_Of_Hours__c
                               FROM Project_Roles__r)
                              FROM Project__c
                              WHERE Id = :proId];   
            List<Id> id_recursos_lista = new List<Id>();
            for(Map<String,Object> recurso: recursos_mapa){
                id_recursos_lista.add((Id)recurso.get('Id'));
            }
            
            List<User> recursos_lista = [SELECT (SELECT Date_Start__c, Date_End__c
                                                 FROM Project_Resources__r
                                                 WHERE Date_End__c < :pro.Date_End__c
                                                 ORDER BY Date_End__c DESC) 
                                         FROM USER
                                         WHERE Id IN : id_recursos_lista];
            List<Project_Resource__c> proyecto_recursos_lista = new List<Project_Resource__c>();
            Map<Id,User> recursos_lista_mapa = new Map<Id,User>(recursos_lista);
            for(Map<String,Object> mapa_recurso:recursos_mapa){
                if(recursos_lista_mapa.get((Id)mapa_recurso.get('Id')).Project_Resources__r.size() == 0){
                    Project_Resource__c proyecto_recurso = new Project_Resource__c();
                    proyecto_recurso.Project__c = proId;
                    proyecto_recurso.Resource__c = (Id)mapa_recurso.get('Id');
                    proyecto_recurso.Date_Start__c = Date.ValueOf((String.ValueOf(mapa_recurso.get('#######'))));
                    proyecto_recurso.Date_End__c = Date.ValueOf((String.ValueOf(mapa_recurso.get('#######'))));
                    proyecto_recursos_lista.add(proyecto_recurso);
                }else if(recursos_lista_mapa.get((Id)mapa_recurso.get('Id')).Project_Resources__r[0].Date_End__c < 
                                                                                                     Date.ValueOf((String.ValueOf(mapa_recurso.get('#######'))))){
                    Project_Resource__c proyecto_recurso = new Project_Resource__c();
                    proyecto_recurso.Project__c = proId;
                    proyecto_recurso.Resource__c = (Id)mapa_recurso.get('Id');
                    proyecto_recurso.Date_Start__c = Date.ValueOf((String.ValueOf(mapa_recurso.get('#######'))));
                    proyecto_recurso.Date_End__c = Date.ValueOf((String.ValueOf(mapa_recurso.get('#######'))));
                    proyecto_recursos_lista.add(proyecto_recurso);
                }else {
                    List<User> usuario_no_registrado = [SELECT Name
                                                        FROM User
                                                        WHERE Id = :(Id)mapa_recurso.get('Id')];
                    //if(!usuario_no_registrado.isEmpty()){
                        usuarios_no_registrados_mapa.put('1', usuario_no_registrado);
                        numero_recursos_no_insertados++;
                    //}
                }
            }
            
            if(!proyecto_recursos_lista.isEmpty()){
                insert proyecto_recursos_lista;
            }
        
            Proyecto_Recursos_No_Registrados instanciada = new Proyecto_Recursos_No_Registrados(numero_recursos_no_insertados, usuarios_no_registrados_mapa);   
        
        */