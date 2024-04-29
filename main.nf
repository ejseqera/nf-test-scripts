process foo {
    echo true

    script:
    '''
    echo $TOKEN_VALUE
    '''
}

