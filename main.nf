process FOO {                                                                      
    debug true                                                                     
                                                                                   
    secret 'USERNAME'                                                              
    secret 'PASSWORD'                                                              
                                                                                   
    script:                                                                        
    """                                                                            
    #!/usr/bin/env bash                                                            
    ##  testing the secret variables                                                      
    echo \$USERNAME                                                                
    echo \$PASSWORD                                                                
    """                                                                                                                                                      
}                                                                                  
                                                                                   
workflow {                                                                         
  FOO()                                                                            
}
