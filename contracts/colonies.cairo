%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import sqrt, unsigned_div_rem

struct Colony:
    member name : felt  # string
    member owner : felt  # address
    member x : felt  # place of power location
    member y : felt  # place of power location
    member plots_amount : felt
    member people : felt
    member food : felt
    member wood : felt
    member ores : felt
    member redirection : felt  # redirect to itself if is destination
end

@storage_var
func colonies(id : felt) -> (colony : Colony):
end

@view
func get_colony{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt) -> (
        colony : Colony):
    # Gets the colony object after multiple redirections
    #
    #   Parameters:
    #       id (felt): the colony id
    #
    #   Returns:
    #       colony (felt): struct after redirections
    let (colony) = colonies.read(id - 1)
    if colony.redirection != id:
        return get_colony(colony.redirection)
    else:
        return (colony)
    end
end

func create_colony{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        name : felt, owner : felt, x : felt, y : felt) -> (id : Colony):
    let (id) = find_available_colony_id(1)
    let colony = Colony(
        name, owner, x, y, plots_amount=0, people=0, food=0, wood=0, ores=0, redirection=id)
    colonies.write(id - 1, colony)
    return (colony)
end

func find_available_colony_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        start : felt) -> (id : felt):
    let (colony) = colonies.read(start - 1)
    if colony.owner == 0:
        return _find_available_colony_id_dichotomia(start / 2, start)
    else:
        return find_available_colony_id(2 * start)
    end
end

func _find_available_colony_id_dichotomia{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        start : felt, last : felt) -> (id : felt):
    if start == last:
        return (start)
    else:
        let (id, _) = unsigned_div_rem(start + last, 2)
        let (colony) = colonies.read(id - 1)
        if colony.owner == 0:
            return _find_available_colony_id_dichotomia(id, last)
        else:
            return _find_available_colony_id_dichotomia(start, id)
        end
    end
end
