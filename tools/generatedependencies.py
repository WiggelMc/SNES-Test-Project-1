#!/usr/bin/env python3

import re, sys

pattern = re.compile(r'([^\;]*)(\.((include)|(incbin))[ \t]+[\'\"])(?P<file>[^\"]+)([\'\"])')

def main(argv=None):
    argv = argv or sys.argv
    
    input_file = argv[1]
    output_file = argv[2]
    obj_file = argv[3]
    
    results = []
    
    f=open(input_file)
    for l in f:
        aa=re.match(pattern,l)
        if aa:
            results.append(aa)
    f.close()
    
    new_results = []
    for e in results:
        ee = e.group("file")
        if "/" in ee:
            new_results.append(ee)
        else:
            new_results.append("src/"+ee)
    
    f=open(output_file, "w+")
    f.write(obj_file+" "+output_file+": "+" ".join(new_results))
    f.close()
    
    print("Dependencies found: ",new_results)

if __name__=='__main__':
    main()