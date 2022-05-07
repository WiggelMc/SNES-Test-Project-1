'use babel';

import fs from 'fs';
import path from 'path';
import os from 'os';
import { exec } from 'child_process';
import voucher from 'voucher';
import { EventEmitter } from 'events';

export const config = {
  jobs: {
    title: 'Simultaneous jobs',
    description: 'Limits how many jobs make will run simultaneously. Defaults to number of processors. Set to 1 for default behavior of make.',
    type: 'number',
    default: os.cpus().length,
    minimum: 1,
    maximum: os.cpus().length,
    order: 1
  },
  gitBashPath: {
    title: 'Path to Git-Bash',
    description: 'Path to lnk-File which links to bash.exe (in /Git/bin/) and is executed in Project Folder (cannot have spaces) [Restart required]',
    type: 'string',
    default: './ExternalTools/atom/build-make/atom-build-make-p.lnk',
    order: 3
  }
};

export function provideBuilder() {
  const gccErrorMatch = '(?<file>([A-Za-z]:[\\/])?[^:\\n]+):(?<line>\\d+):(?<col>\\d+):\\s*(fatal error|error):\\s*(?<message>.+)';
  const gfortranErrorMatch = '(?<file>[^:\\n]+):(?<line>\\d+):(?<col>\\d+):[\\s\\S]+?Error: (?<message>.+)';
  const ocamlErrorMatch = '(?<file>[\\/0-9a-zA-Z\\._\\-]+)", line (?<line>\\d+), characters (?<col>\\d+)-(?<col_end>\\d+):\\n(?<message>.+)';
  const golangErrorMatch = '(?<file>([A-Za-z]:[\\/])?[^:\\n]+):(?<line>\\d+):\\s*(?<message>.*error.+)';
  const cc65ErrorMatch = '(?<file>([A-Za-z]:[\\/])?[^:\\n]+\\.[^:\\n]+):(?<line>\\d+): Error:\\s*(?<message>.*)';
  const errorMatch = [
    cc65ErrorMatch
  ];

  const gccWarningMatch = '(?<file>([A-Za-z]:[\\/])?[^:\\n]+):(?<line>\\d+):(?<col>\\d+):\\s*(warning):\\s*(?<message>.+)';
  const warningMatch = [
    gccWarningMatch
  ];

  return class MakeBuildProvider extends EventEmitter {
    constructor(cwd) {
      super();
      this.cwd = cwd;
      atom.config.observe('build-make.jobs', () => this.emit('refresh'));
    }

    getNiceName() {
      return 'GNU Make';
    }

    isEligible() {
      this.files = [ 'Makefile', 'GNUmakefile', 'makefile' ]
        .map(f => path.join(this.cwd, f))
        .filter(fs.existsSync);
      return this.files.length > 0;
    }

    settings() {
	  const jobArg = `-j${atom.config.get('build-make.jobs')}`
		
      const defaultTarget = {
        exec: atom.config.get('build-make.gitBashPath'),
        name: 'GNU Make: default (no target)',
        args: ["-c","make "+jobArg],
        sh: false,
        errorMatch: errorMatch,
        warningMatch: warningMatch
      };

      const promise = voucher(fs.readFile, this.files[0]); // Only take the first file

      return promise.then(output => {
        return [ defaultTarget ].concat(output.toString('utf8')
          .split(/[\r\n]{1,2}/)
          .filter(line => /^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/.test(line))
          .map(targetLine => targetLine.split(':').shift())
          .filter( (elem, pos, array) => (array.indexOf(elem) === pos) )
          .map(target => ({
            exec: atom.config.get('build-make.gitBashPath'),
            args: ["-c","make "+jobArg+" "+target],
            name: `GNU Make: ${target}`,
            sh: false,
            errorMatch: errorMatch,
            warningMatch: warningMatch
          })));
      }).catch(e => [ defaultTarget ]);
    }
  };
}
