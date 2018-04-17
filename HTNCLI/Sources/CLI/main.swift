import SwiftCLI
import Rainbow
import Core

Rainbow.enabled = Term.isTTY

let _verbose = Flag("-v", "--verbose")
extension Command {
    var verbose: Flag {
        return _verbose
    }
    
    func verboseLog(_ content: String) {
        if verbose.value {
            stdout <<< content
        }
    }
}

let htn = CLI(name: "htn", version: HTNCLI.version, description: "HTN toolkit")
htn.commands = [
    BuildCommand()
]
htn.globalOptions = [_verbose]
htn.goAndExit()
