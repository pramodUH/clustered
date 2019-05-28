function [best_value, best_solution, convergence ] = DE1(objective_function, linear_tables_GO, pLi, init_max, init_min, no_of_dimensions, population_size, no_of_iterations, prev_pg, generator_mapping)

    CR = 0.95;
    move_max = init_max;
    move_min = init_min;
	population = rand(no_of_dimensions, population_size).*repmat((init_max - init_min),1,population_size) + repmat(init_min,1,population_size);
	temp_buffer = zeros(no_of_dimensions, population_size);
    population(:,1) = prev_pg;
    
    fitness = zeros(population_size, 1);
    for i = 1:1:population_size
        fitness(i) = feval(objective_function, population(:,i), linear_tables_GO, pLi, generator_mapping);
    end
    
	convergence = zeros(no_of_iterations+1,1);
	convergence(1) = min(fitness);
    

	for iteration = 1:1:no_of_iterations
	    for i = 1:1:population_size
            p1 = randi([1,population_size-1]);
            if(p1 >= i)
                p1 = p1 +1;
            end
            p2 = randi([1, population_size-2]);
            t2 = p2;
            if(p2 >= i)
                t2 = t2 +1;
            end
            if(p2 >= p1)
                t2 = t2 +1;
            end
            p2 = t2;
            p3 = randi([1, population_size-3]);
            t3 = p3;
            if(p3 >= i)
                t3 = t3 +1;
            end
            if(p3 >= p1)
                t3 = t3 +1;
            end
            if(p3 >= p2)
                t3 = t3 +1;
            end
            p3 = t3;
            p4 = randi([1, population_size-4]);
            t4 = p4;
            if(p4 >= i)
                t4 = t4 +1;
            end
            if(p4 >= p1)
                t4 = t4 +1;
            end
            if(p4 >= p2)
                t4 = t4 +1;
            end
            if(p4 >= p3)
                t4 = t4 +1;
            end
            p4 = t4;
            delta = ((population(:,p1) - population(:,p2)) + (population(:,p3) - population(:,p4)))/2;
            offspring = population(:,i) + delta;
            for j = 1:1:no_of_dimensions
                if(offspring(j) > move_max(j))
                    offspring(j) = move_max(j);
                elseif(offspring(j) < move_min(j))
                    offspring(j) = move_min(j);
                end
            end
            for j = 1:1:no_of_dimensions
                r = rand();
                if(r > CR)
                    offspring(j) = population(j,i); 
                end
            end
            result = feval(objective_function, offspring, linear_tables_GO, pLi, generator_mapping);
            if(result < fitness(i))
                fitness(i) = result;
                temp_buffer(:,i) = offspring;
            else
                temp_buffer(:,i) = population(:,i);
            end
	    end
	    convergence(iteration+1) = min(fitness);
	    population = temp_buffer;
	end

	best_value = fitness(1);
	best_solution = population(:,1);
	for i = 1:1:population_size
	    if(fitness(i) < best_value)
		best_value = fitness(i);
		best_solution = population(:,i);
	    end
	end
end
