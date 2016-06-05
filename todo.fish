function todo
    # Sources configuration file for ID -> Name Mappings
    source ~/etc/todo.conf

    # Set board and list IDs to default
    set boardID $ToDo
    set listID $Today
    if test (count $argv) -gt 0 
        set add false
        set delete false
        set help false

        # Checks whether board flag was specified, sets board if so
        getopts $argv | grep '^b' > /dev/null
        if test (echo $status) -eq 0
            set board (getopts $argv | grep '^b' | cut -d" " -f2)
            set boardID (grep $board ~/etc/todo.conf | cut -d" " -f3)
        end

        # Checks whether list flag was specified, sets list if so
        getopts $argv | grep '^l' > /dev/null
        if test (echo $status) -eq 0
            set list (getopts $argv | grep '^l' | cut -d" " -f2)
            set listID (grep $list ~/etc/todo.conf | cut -d" " -f3)
        end
        
        # Proceeds to flags
        getopts $argv | while read -l key value
            switch $key
                # Help Command
                case h
                    set help true
                    echo '[*] Todo list functionality via Trello CLI'
                    echo '[*] Usage: todo [options] [task] (Enclose the tasks in quotes "")'
                    echo '[*] Arguments: ' 
                    echo '[*] -a <task name> : Brings up interactive CLI for adding tasks to todo list.'
                    echo '[*] -d <task name> : Deletes task. '
                    echo '[*] -l <list> : Use a given list (defaults to today) '
                    echo '[*] -b <board> : Use a given board (defaults to todo) ' 
                    echo '[*] -c : configures board/list ID mappings '

                # Add Command
                case a
                    set add true
                    echo "Add notes to the task if necessary"
                    read description </dev/tty
                    trello card create -b $boardID -l $listID -n "$value" -d "$description"
                case d
                    # temporary solution, only works on default todo board
                    set delete true
                    trello card move -c $value -l 57536438e19d5314b2134241
            end
        end
        # Tests to see if delete or add flags have been added, runs search if not
        if test (echo $add) = false -a (echo $delete) = false -a (echo $help) = false
            trello card list -b $boardID -l $listID 
            
        end
    else
        trello card list -b $boardID -l $listID 
    end
end
