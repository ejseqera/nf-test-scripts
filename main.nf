process FOO {                                                                      
    debug true                                                                     
                                                                                   
    secret 'ALT_USER'                                                              
    secret 'ALT_PASS'                                                              
                                                                                   
    script:                                                                        
    """                                                                            
    #!/usr/bin/env bash                                                            
    ##  testing the secret variables                                                      
    echo \$ALT_USER                                                                
    echo \$ALT_PASS                                                                
    """                                                                                                                                                      
}                                                                                  
                                                                                   
workflow {                                                                         
  FOO()                                                                            
}
