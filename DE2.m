function [best_value, best_solution, convergence] = DE2(pg, objective_function, generator_data_GO, branch_data_GO, transformer_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, bus_info, pLi, qLi, gFSi, bFSi, bCSi, no_of_buses, Rbare, Sbarf, lambdaPn, lambdaQn, lambdaen, limits, init_max, init_min, SBASE, prev, no_of_dimensions, no_of_iterations, population_size, cluster, mirrored)

    CR = 0.95;
    move_max = init_max;
    move_min = init_min;

    no_of_system_buses = length(prev)/2;
	temp_buffer = zeros(no_of_dimensions, population_size);
    population = rand(no_of_dimensions, population_size) .* repmat((init_max - init_min),1,population_size) + repmat(init_min,1,population_size); 
    v = zeros(length(cluster),1);
    theta = zeros(length(cluster),1);    
    fitness = zeros(population_size,1);
    
    for i = 1:1:population_size
        point1 = 1;
        point2 = 1;
        for j = 1:1:length(cluster)
            if(point1<=length(mirrored) && j == mirrored(point1))
                v(j) = prev(cluster(j));
                theta(j) = prev(cluster(j) + no_of_system_buses);
                point1 = point1+1;
            else
                v(j) = population(point2,i);
                theta(j) = population(point2+no_of_dimensions/2,i);
                point2 = point2+1;
            end
        end
        qg = get_qg(v, theta, bus_info, qLi, branch_data_GO, transformer_data_GO, generator_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, SBASE);
        fitness(i) = feval(objective_function, pg, qg, v, theta, branch_data_GO, transformer_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, bus_info, pLi, qLi, gFSi, bFSi, bCSi, no_of_buses, Rbare, Sbarf, lambdaPn, lambdaQn, lambdaen, limits);            
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
        
        
        p5 = randi([1, population_size-5]);
		t5 = p5;
		if(p5 >= i)
		    t5 = t5 +1;
		end
		if(p5 >= p1)
		    t5 = t5 +1;
		end
		if(p5 >= p2)
		    t5 = t5 +1;
		end
		if(p5 >= p3)
		    t5 = t5 +1;
        end
        if(p5 >= p4)
		    t5 = t5 +1;
		end
		p5 = t5;
        
        p6 = randi([1, population_size-6]);
		t6 = p6;
		if(p6 >= i)
		    t6 = t6 +1;
		end
		if(p6 >= p1)
		    t6 = t6 +1;
		end
		if(p6 >= p2)
		    t6 = t6 +1;
		end
		if(p6 >= p3)
		    t6 = t6 +1;
        end
        if(p6 >= p4)
		    t6 = t6 +1;
        end
        if(p6 >= p5)
		    t6 = t6 +1;
		end
		p6 = t6;
        
        %delta = ((population(:,p1) - population(:,p2)) + (population(:,p3) - population(:,p4))+(population(:,p5) - population(:,p6)))/3;
		delta = ((population(:,p1) - population(:,p2)) + (population(:,p3) - population(:,p4)))/2;
        %delta = (population(:,p1) - population(:,p2));
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
        
        point1 = 1;
        point2 = 1;
        for j = 1:1:length(cluster)
            if(point1<=length(mirrored) && j == mirrored(point1))
                point1 = point1+1;
            else
                v(j) = offspring(point2);
                theta(j) = offspring(point2+no_of_dimensions/2);
            end
        end
        qg = get_qg(v, theta, bus_info, qLi, branch_data_GO, transformer_data_GO, generator_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, SBASE);
        result = feval(objective_function, pg, qg, v, theta, branch_data_GO, transformer_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, bus_info, pLi, qLi, gFSi, bFSi, bCSi, no_of_buses, Rbare, Sbarf, lambdaPn, lambdaQn, lambdaen, limits);
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
