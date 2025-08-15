process FOO {                                                                      
    debug true                                                                     
                                                                                   
    secret 'ALT_USER'                                                              
    secret 'ALT_PASS'                                                              
                                                                                   
    script:                                                                        
    """                                                                            
    ##  testing the secret variables                                                      
    echo \$ALT_USER                                                                
    echo \$ALT_PASS                                                                
    """                                                                                                                                                      
}                                                                                  
                                                                                   
workflow {                                                                         
  FOO()                                                                            
}
