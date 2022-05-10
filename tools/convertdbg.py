#!/usr/bin/env python3

import re, sys

labelIndicator = '=lab'
val_pattern = re.compile(r'(val=0x)(?P<val>[\d\w]+)')
name_pattern = re.compile(r'(name=\")(?P<name>[^\"]+)(\")')
scope_pattern = re.compile(r'(scope=)(?P<scope>[\d]+)')


def main(argv=None):
    argv = argv or sys.argv
    
    input_file = argv[1]
    output_file = argv[2]
    
    results = []
    
    f=open(input_file)
    for l in f:
        if len(l) >= 5:
            aa=l[-5:-1]
            if (aa == labelIndicator):
                val = re.search(val_pattern, l).group('val')
                name = re.search(name_pattern, l).group('name')
                
                results.append("LIST "+name+" = $"+val)
                #scope = re.search(scope_pattern, l).group('scope')
            
    f.close()
    
    #new_results = []
    #for e in results:
    #    ee = e.group("file")
    #    if "/" in ee:
    #        new_results.append(ee)
    #    else:
    #        new_results.append("src/"+ee)
    
    f=open(output_file, "w+")
    f.write("\n".join(results))
    f.close()
    
    print("DBG-File converted")

if __name__=='__main__':
    main()