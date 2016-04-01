
# === {{CMD}}
# === {{CMD}}    up
# === {{CMD}}    down
# === {{CMD}}    reset
# === {{CMD}}    reset   MODEL
# === {{CMD}}    default_data
# === {{CMD}}    create  MODEL name
# === {{CMD}}    status
migrate () {
    if [[ -z "$@" ]]; then
      sub_action="up"
    else
      sub_action="$1"
      shift
    fi

    case "$sub_action" in
      "create")
        model="$1"
        name="$2"
        shift
        shift
        cd lib
        duck_duck_duck create $model $name
        ;;

      "reset")
        model="$@"

        bin/megauni migrate down "$model"
        bin/megauni migrate up   "$model"
        echo ""
        # if [[ -z "$model" ]]; then
          # ALLOW_BANNED_SCREEN_NAME=true bin/megauni migrate default_data
        # fi
        # echo -e "\n===== DONE =====\n"
        ;;

      "default_data")
        bin/migrate_default_data
        ;;

      "status")
        script="
          require 'sequel'
          DB = Sequel.connect('$DATABASE_URL')
          if DB.table_exists?(:_schema)
            rows = []
            DB.from(:_schema).each { |r|
              rows << r
              puts r.inspect
            }
            puts '== No records found.' if rows.empty?
          else
            puts '== Table not found.'
          end
        "
        ruby -e "$script"
        ;;

      "up")
        model="$@"

        if [[ -z "$model" ]]
        then
          for m in ${mods[@]}
          do
            bin/megauni migrate up $m
          done
          echo -e "\n=== Done.\n"
        else
          cd lib
          echo ""
          duck_duck_duck up $model
        fi
        ;;

      "down")
        model="$@"

        if [[ -z "$model" ]]
        then

          # === Ensure dev machine.
          if [ ! -n "${IS_DEV+x}" ]
          then
            echo "This is not a dev machine."
            exit 1
          fi

          # === Reverse list
          for m in ${rev_mods[@]}
          do
            bin/megauni migrate down $m
          done

        else
          cd lib
          echo ""
          duck_duck_duck down $model
        fi
        ;;

      *)
        echo "Unknown command for migrate: $sub_action"
        exit 1
        ;;
    esac # === sub_action
} # === end function
