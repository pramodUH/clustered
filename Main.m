clear
clc
% cluster{1} = [1, 2, 5, 6, 9, 10, 11, 12, 13, 14];
% cluster{2} = [3, 4, 7, 8];

cluster{1} = [1, 5, 6, 10, 11, 12, 13, 14];
cluster{2} = [2, 3, 4, 7, 8, 9];

readdata;


SBASE = case_identification_data_GO(1);
for i = 1:1:length(linear_tables_GO)
    table = linear_tables_GO{i};
    table(:,1) = table(:,1)/SBASE;
    linear_tables_GO{i} = table;
end

system_info.bus_data_GO = bus_data_GO;
system_info.load_data_GO = load_data_GO;
system_info.fixed_bus_shunt_data_GO = fixed_bus_shunt_data_GO;
system_info.generator_data_GO = generator_data_GO;
system_info.branch_data_GO = branch_data_GO;
system_info.transformer_data_GO = transformer_data_GO;
system_info.switched_shunt_data_GO = switched_shunt_data_GO;

cluster_info(1) = struct();
for cl = 1:1:length(cluster)
    
    bus_status = zeros(size(bus_data_GO,1),1);
    load_status = zeros(size(load_data_GO,1),1);
    fixed_shunt_status = zeros(size(fixed_bus_shunt_data_GO,1),1);
    generator_status = zeros(size(generator_data_GO,1),1);
    branch_status = zeros(size(branch_data_GO,1),1);
    transformer_status = zeros(size(transformer_data_GO,1),1);
    switched_shunt_status = zeros(size(switched_shunt_data_GO,1),1);

    for i = 1:1:length(cluster{cl})
        bus_status(cluster{cl}(i)) = 1;
    end
    for i = 1:1:size(load_data_GO,1)
        bus = load_data_GO(i,1);
        if(bus_status(bus) == 1)
            load_status(i) = 1;
        end    
    end
    for i = 1:1:size(fixed_bus_shunt_data_GO,1)
        bus = fixed_bus_shunt_data_GO(i,1);
        if(bus_status(bus) == 1)
            fixed_shunt_status(i) = 1;
        end
    end
    for i = 1:1:size(generator_data_GO,1)
        bus = generator_data_GO(i,1);
        if(bus_status(bus) == 1)
            generator_status(i) = 1;
        end
    end
    for i = 1:1:size(branch_data_GO,1)
        origin_bus = branch_data_GO(i,1);
        destination_bus = branch_data_GO(i,2);
        if(bus_status(origin_bus) == 1 && bus_status(destination_bus) == 1)
            branch_status(i) = 1;
        end
    end
    for i = 1:1:size(transformer_data_GO,1)
        origin_bus = transformer_data_GO(i,1);
        destination_bus = transformer_data_GO(i,2);
        if(bus_status(origin_bus) == 1 && bus_status(destination_bus) == 1)
            transformer_status(i) = 1;
        end
    end
    for i = 1:1:size(switched_shunt_data_GO,1)
        bus = switched_bus_shunt_data_GO(i,1);
        if(bus_status(bus) == 1)
            switched_shunt_status(i) = 1;
        end
    end

    cluster_bus_data_GO = zeros(sum(bus_status),size(bus_data_GO,2));
    cluster_bus_mapping = zeros(size(bus_data_GO,1),1);
    count = 1;
    for i = 1:1:size(bus_data_GO,1)
        if(bus_status(i) == 1)
            cluster_bus_data_GO(count,:) = bus_data_GO(i,:);
            cluster_bus_data_GO(count,1) = count;
            cluster_bus_mapping(i) = count;
            count = count+1;
        end
    end
    cluster_info(cl).bus_data_GO = cluster_bus_data_GO;
    cluster_info(cl).bus_mapping = cluster_bus_mapping;

    cluster_load_data_GO = zeros(sum(load_status),size(load_data_GO,2));
    count = 1;
    for i = 1:1:size(load_data_GO,1)
        if(load_status(i) == 1)
            cluster_load_data_GO(count,:) = load_data_GO(i,:);
            cluster_load_data_GO(count,1) = cluster_bus_mapping(load_data_GO(i,1));
            count = count +1;
        end
    end
    cluster_info(cl).load_data_GO = cluster_load_data_GO;

    cluster_fixed_bus_shunt_data_GO = zeros(sum(fixed_shunt_status),size(fixed_bus_shunt_data_GO,2));
    count = 1;
    for i = 1:1:size(fixed_bus_shunt_data_GO,1)
        if(fixed_shunt_status(i) == 1)
            cluster_fixed_bus_shunt_data_GO(count,:) = fixed_bus_shunt_data_GO(i,:);
            cluster_fixed_bus_shunt_data_GO(count,1) = cluster_bus_mapping(fixed_bus_shunt_data_GO(i,1));
            count = count +1;
        end
    end
    cluster_info(cl).fixed_bus_shunt_data_GO = cluster_fixed_bus_shunt_data_GO;

    cluster_generator_data_GO = zeros(sum(generator_status),size(generator_data_GO,2));
    cluster_generator_mapping = zeros(size(generator_data_GO,1),1);
    count = 1;
    for i = 1:1:size(generator_data_GO,1)
        if(generator_status(i) == 1)
            cluster_generator_data_GO(count,:) = generator_data_GO(i,:);
            cluster_generator_data_GO(count,1) = cluster_bus_mapping(generator_data_GO(i,1));
            cluster_generator_mapping(count) = i;
            count = count +1;
        end
    end
    cluster_info(cl).generator_data_GO = cluster_generator_data_GO;
    cluster_info(cl).generator_mapping = cluster_generator_mapping;

    cluster_branch_data_GO = zeros(sum(branch_status),size(branch_data_GO,2));
    count = 1;
    for i = 1:1:size(branch_data_GO,1)
        if(branch_status(i) == 1)
            cluster_branch_data_GO(count,:) = branch_data_GO(i,:);
            cluster_branch_data_GO(count,1) = cluster_bus_mapping(branch_data_GO(i,1));
            cluster_branch_data_GO(count,2) = cluster_bus_mapping(branch_data_GO(i,2));
            count = count +1;
        end
    end
    cluster_info(cl).branch_data_GO = cluster_branch_data_GO;

    cluster_transformer_data_GO = zeros(sum(transformer_status),size(transformer_data_GO,2));
    count = 1;
    for i = 1:1:size(transformer_data_GO,1)
        if(transformer_status(i) == 1)
            cluster_transformer_data_GO(count,:) = transformer_data_GO(i,:);
            cluster_transformer_data_GO(count,1) = cluster_bus_mapping(transformer_data_GO(i,1));
            cluster_transformer_data_GO(count,2) = cluster_bus_mapping(transformer_data_GO(i,2));
            count = count +1;
        end
    end
    cluster_info(cl).transformer_data_GO = cluster_transformer_data_GO;

    cluster_switched_shunt_data_GO = zeros(sum(switched_shunt_status),size(switched_shunt_data_GO,2));
    count = 1;
    for i = 1:1:size(switched_shunt_data_GO,1)
        if(switched_shunt_status(i) == 1)
            cluster_switched_shunt_data_GO(count,:) = switched_shunt_data_GO(i,:);
            cluster_switched_shunt_data_GO(count,1) = cluster_bus_mapping(switched_shunt_data_GO(i,1));
            count = count +1;
        end
    end
    cluster_info(cl).switched_shunt_data_GO = cluster_switched_shunt_data_GO;
    
    % Validity of the clusters

    if(sum(cluster_load_data_GO(:,3)) > sum(cluster_generator_data_GO(:,7)) || sum(cluster_load_data_GO(:,3)) < sum(cluster_generator_data_GO(:,8)))
        error('Real power balance: cluster %d', cl);
    end
    if(sum(cluster_load_data_GO(:,4)) > sum(cluster_generator_data_GO(:,4)) || sum(cluster_load_data_GO(:,4)) < sum(cluster_generator_data_GO(:,5)))
        error('Reactive power balance: cluster %d', cl);
    end 
    
end


cluster_results = cell(length(cluster_info),1);

for cl = 1:1:length(cluster_info)
    cl
    bus_data_GO = cluster_info(cl).bus_data_GO;
    load_data_GO = cluster_info(cl).load_data_GO;
    fixed_bus_shunt_data_GO = cluster_info(cl).fixed_bus_shunt_data_GO;
    generator_data_GO = cluster_info(cl).generator_data_GO;
    branch_data_GO = cluster_info(cl).branch_data_GO;
    transformer_data_GO = cluster_info(cl).transformer_data_GO;
    switched_shunt_data_GO = cluster_info(cl).switched_shunt_data_GO;
    generator_mapping = cluster_info(cl).generator_mapping;

    R = branch_data_GO(:,3);
    X = branch_data_GO(:,4);
    B = branch_data_GO(:,5);
    R12 = transformer_data_GO(:,6);
    X12 = transformer_data_GO(:,7); 
    WINDV1 = transformer_data_GO(:,8);
    WINDV2 = transformer_data_GO(:,12);
    ANG1 = transformer_data_GO(:,9);
    MAG1 = transformer_data_GO(:,3);
    MAG2 = transformer_data_GO(:,4);
    ge = R ./ (R.^2 + X.^2);
    be = -X ./ (R.^2 + X.^2);
    thetaf = ANG1 * pi/180;
    bCHe = B;
    gf = R12 ./ (R12.^2 + X12.^2);
    bf = -(X12) ./ (R12.^2 + X12.^2);
    tauf = WINDV1 ./ WINDV2;
    gMf = MAG1;
    bMf = MAG2;
    
    I = load_data_GO(:,1);
    STATUS = load_data_GO(:,2);
    PL = load_data_GO(:,3);
    QL = load_data_GO(:,4);
    s_tilde = SBASE;

    no_of_generators = size(generator_data_GO,1);
    no_of_buses = size(bus_data_GO,1);

    pLi = zeros(no_of_buses,1);
    qLi = zeros(no_of_buses,1);
    for i=1:1:size(I,1)
        if(STATUS(i) == 1)
            pLi(I(i)) = pLi(I(i)) + PL(i)/s_tilde;
            qLi(I(i)) = qLi(I(i)) + QL(i)/s_tilde;
        end
    end

    buses_with_generators = generator_data_GO(:,1);
    bus_info(1) = struct('generator_list', [], 'origin_list', [], 'destination_list', [], 'transformer_origin_list', [], 'transformer_destination_list', []); 
    for k=no_of_buses:-1:2
        bus_info(k) = struct('generator_list', [], 'origin_list',[], 'destination_list', [], 'transformer_origin_list', [], 'transformer_destination_list', []);
    end

    for k=1:1:size(buses_with_generators,1)
        bus_info(buses_with_generators(k)).generator_list = [bus_info(buses_with_generators(k)).generator_list k]; 
    end

    gFSi = zeros(no_of_buses,1);
    bFSi = zeros(no_of_buses,1);

    origin = branch_data_GO(:,1);
    destination = branch_data_GO(:,2);

    for k=1:1:size(origin,1)
        bus_info(origin(k)).origin_list = [bus_info(origin(k)).origin_list k];
    end

    for k=1:1:size(destination,1)
        bus_info(destination(k)).destination_list = [bus_info(destination(k)).destination_list k];
    end

    origin = transformer_data_GO(:,1);
    destination = transformer_data_GO(:,2);
    for k=1:1:size(origin,1)
        bus_info(origin(k)).transformer_origin_list = [bus_info(origin(k)).transformer_origin_list k];
    end

    for k=1:1:size(destination,1)
        bus_info(destination(k)).transformer_destination_list = [bus_info(destination(k)).transformer_destination_list k];
    end

    if(~isempty(fixed_bus_shunt_data_GO))
        I = fixed_bus_shunt_data_GO(:,1);
        STATUS = fixed_bus_shunt_data_GO(:,2);
        GL = fixed_bus_shunt_data_GO(:,3);
        BL = fixed_bus_shunt_data_GO(:,4);
        for i=1:1:size(I,1)
            if(STATUS(i) ==1)
                gFSi(I(i)) = gFSi(I(i)) + GL(i)/s_tilde;
                bFSi(I(i)) = bFSi(I(i)) + BL(i)/s_tilde;   
            end
        end
    end

    bCSi = zeros(no_of_buses,1);
    RATEA = branch_data_GO(:,6);
    RATA1 = transformer_data_GO(:,10);
    Rbare = RATEA ./ s_tilde;
    Sbarf = RATA1 ./ s_tilde;
    costs =  [1000, 5000, 1000000; 1000, 5000, 1000000; 1000, 5000, 1000000];
    limits = [2 50 Inf; 2 50 Inf; 2 50 Inf]/SBASE;

    lambdaPn = costs(1,:) * SBASE;
    lambdaQn = costs(2,:) * SBASE; 
    lambdaen = costs(3,:) * SBASE;  

    delta = 0.5;

    %rng(2);

    ng_list = zeros(no_of_buses - no_of_generators, 1);
    all_buses = zeros(no_of_buses, 1);
    for i = 1:1:size(generator_data_GO,1)
        all_buses(generator_data_GO(i,1)) = -1;
    end
    count = 1;
    for i = 1:1:no_of_buses
        if(all_buses(i) == 0)
            ng_list(count) = i;
            count = count +1;
        end
    end

    %----------------CLUSTERING------------------------------------------------
    %[clusters, bus_to_cluster, branches_list] = createClusters(branch_data_GO, transformer_data_GO);
    clusters = containers.Map('KeyType','int64','ValueType','any');
    clusters(1)=[1:no_of_buses];
    bus_to_cluster = ones(1,no_of_buses);
    %branches_list = [1:14];
    %---------------CLUSTERING ENDS HERE---------------------------------------


    pg = (generator_data_GO(:,7) + generator_data_GO(:,8))/(2*SBASE);
    pg_new = pLi;
    prev = [ones(no_of_buses,1); zeros(no_of_buses,1)];


    iterations_start=300;
    iterations_end=300;
    outer_iterations = 1;
    iterations = iterations_start;
    iterations_diff = (iterations_end-iterations_start)/outer_iterations;

    csigma_loop = zeros(outer_iterations,1);
    cg_loop = zeros(outer_iterations,1);
    sigma_p_loop = zeros(outer_iterations,1);
    sigma_q_loop = zeros(outer_iterations,1);
    c_loop = zeros(outer_iterations,1);
    pg_loop = zeros(no_of_generators,outer_iterations);
    sum_pg_loop = zeros(outer_iterations,1);

    for k = 1:1:outer_iterations
        k
        objective_function = @get_cg_pg;
        pos_max = generator_data_GO(:,7)/SBASE;
        pos_min = generator_data_GO(:,8)/SBASE;
        no_of_dimensions = no_of_generators;
        no_of_particles = 20;
        no_of_iterations = iterations;
        prev_pg = pg;
        [gbest_val, gbest_loc, convergence] = DE1(objective_function, linear_tables_GO, pg_new, pos_max, pos_min, no_of_dimensions, no_of_particles, no_of_iterations, prev_pg, generator_mapping);
        pg = gbest_loc
        sum(pg);
        cg = gbest_val    
        no_of_dimensions = 2*no_of_buses;
        objective_function = @get_csigma;
        no_of_iterations = iterations; 
        no_of_particles = 20;
        pos_max = [1.05*ones(no_of_buses,1); 0.05*pi*ones(no_of_buses,1)];
        pos_min = [0.95*ones(no_of_buses,1); -0.05*pi*ones(no_of_buses,1)];
        [gbest_val, gbest_loc, convergence] = DE2(pg, objective_function, generator_data_GO, branch_data_GO, transformer_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, bus_info, pLi, qLi, gFSi, bFSi, bCSi, no_of_buses, Rbare, Sbarf, lambdaPn, lambdaQn, lambdaen, limits, pos_max, pos_min, SBASE, prev, no_of_dimensions, no_of_iterations, no_of_particles, clusters(1));
        prev = gbest_loc;
        v = gbest_loc(1:no_of_buses);
        theta = gbest_loc(no_of_buses+1:end); 
        qg = get_qg(v, theta, bus_info, qLi, branch_data_GO, transformer_data_GO, generator_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, SBASE);
        csigma = feval(objective_function, pg, qg, v, theta, branch_data_GO, transformer_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, bus_info, pLi, qLi, gFSi, bFSi, bCSi, no_of_buses, Rbare, Sbarf, lambdaPn, lambdaQn, lambdaen, limits);
        csigma
        qg = get_qg(v, theta, bus_info, qLi, branch_data_GO, transformer_data_GO, generator_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, SBASE);
        [~, csigma_p, csigma_q, sigmase, sigmafe] = get_excess(pg, qg, v, theta, branch_data_GO, transformer_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, bus_info, pLi, qLi, gFSi, bFSi, bCSi, no_of_buses, Rbare, Sbarf, lambdaPn, lambdaQn, lambdaen, limits);
        csigma_p
        csigma_q
        sigmase 
        sigmafe
        pg_new=sum(pg)-csigma_p
        cg_pg_new=get_cg(pg, linear_tables_GO, generator_mapping)
        c=cg_pg_new+delta*csigma
        iterations = iterations + iterations_diff

        csigma_loop(k) = csigma;
        cg_loop(k) = cg_pg_new;
        sigma_p_loop(k) = csigma_p;
            sigma_q_loop(k) = csigma_q;
            c_loop(k) = c;
            pg_loop(:,k) = pg;
            sum_pg_loop(k) = sum(pg);

        end

    figure;
    subplot(3,2,1);
    plot(csigma_loop);
    title('csigma');

    subplot(3,2,2);
    plot(cg_loop);
    title('cg');

    subplot(3,2,3);
    plot(sigma_p_loop);
    title('sigma p');

    subplot(3,2,4);
    plot(sigma_q_loop);
    title('sigma q');

    subplot(3,2,5);
    plot(c_loop);
    title('cost');

    subplot(3,2,6);
    plot(sum_pg_loop);
    title('sum of pg');
    
    cluster_results{cl} = [gbest_loc; pg]; 
end

bus_data_GO = system_info.bus_data_GO;
load_data_GO = system_info.load_data_GO;
fixed_bus_shunt_data_GO = system_info.fixed_bus_shunt_data_GO;
generator_data_GO = system_info.generator_data_GO;
branch_data_GO = system_info.branch_data_GO;
transformer_data_GO = system_info.transformer_data_GO;
switched_shunt_data_GO = system_info.switched_shunt_data_GO;
generator_mapping = 1:1:size(generator_data_GO,1);

    R = branch_data_GO(:,3);
    X = branch_data_GO(:,4);
    B = branch_data_GO(:,5);
    R12 = transformer_data_GO(:,6);
    X12 = transformer_data_GO(:,7); 
    WINDV1 = transformer_data_GO(:,8);
    WINDV2 = transformer_data_GO(:,12);
    ANG1 = transformer_data_GO(:,9);
    MAG1 = transformer_data_GO(:,3);
    MAG2 = transformer_data_GO(:,4);
    ge = R ./ (R.^2 + X.^2);
    be = -X ./ (R.^2 + X.^2);
    thetaf = ANG1 * pi/180;
    bCHe = B;
    gf = R12 ./ (R12.^2 + X12.^2);
    bf = -(X12) ./ (R12.^2 + X12.^2);
    tauf = WINDV1 ./ WINDV2;
    gMf = MAG1;
    bMf = MAG2;
    
    I = load_data_GO(:,1);
    STATUS = load_data_GO(:,2);
    PL = load_data_GO(:,3);
    QL = load_data_GO(:,4);
    s_tilde = SBASE;

    no_of_generators = size(generator_data_GO,1);
    no_of_buses = size(bus_data_GO,1);

    pLi = zeros(no_of_buses,1);
    qLi = zeros(no_of_buses,1);
    for i=1:1:size(I,1)
        if(STATUS(i) == 1)
            pLi(I(i)) = pLi(I(i)) + PL(i)/s_tilde;
            qLi(I(i)) = qLi(I(i)) + QL(i)/s_tilde;
        end
    end

    buses_with_generators = generator_data_GO(:,1);
    bus_info(1) = struct('generator_list', [], 'origin_list', [], 'destination_list', [], 'transformer_origin_list', [], 'transformer_destination_list', []); 
    for k=no_of_buses:-1:2
        bus_info(k) = struct('generator_list', [], 'origin_list',[], 'destination_list', [], 'transformer_origin_list', [], 'transformer_destination_list', []);
    end

    for k=1:1:size(buses_with_generators,1)
        bus_info(buses_with_generators(k)).generator_list = [bus_info(buses_with_generators(k)).generator_list k]; 
    end

    gFSi = zeros(no_of_buses,1);
    bFSi = zeros(no_of_buses,1);

    origin = branch_data_GO(:,1);
    destination = branch_data_GO(:,2);

    for k=1:1:size(origin,1)
        bus_info(origin(k)).origin_list = [bus_info(origin(k)).origin_list k];
    end

    for k=1:1:size(destination,1)
        bus_info(destination(k)).destination_list = [bus_info(destination(k)).destination_list k];
    end

    origin = transformer_data_GO(:,1);
    destination = transformer_data_GO(:,2);
    for k=1:1:size(origin,1)
        bus_info(origin(k)).transformer_origin_list = [bus_info(origin(k)).transformer_origin_list k];
    end

    for k=1:1:size(destination,1)
        bus_info(destination(k)).transformer_destination_list = [bus_info(destination(k)).transformer_destination_list k];
    end

    if(~isempty(fixed_bus_shunt_data_GO))
        I = fixed_bus_shunt_data_GO(:,1);
        STATUS = fixed_bus_shunt_data_GO(:,2);
        GL = fixed_bus_shunt_data_GO(:,3);
        BL = fixed_bus_shunt_data_GO(:,4);
        for i=1:1:size(I,1)
            if(STATUS(i) ==1)
                gFSi(I(i)) = gFSi(I(i)) + GL(i)/s_tilde;
                bFSi(I(i)) = bFSi(I(i)) + BL(i)/s_tilde;   
            end
        end
    end

    bCSi = zeros(no_of_buses,1);
    RATEA = branch_data_GO(:,6);
    RATA1 = transformer_data_GO(:,10);
    Rbare = RATEA ./ s_tilde;
    Sbarf = RATA1 ./ s_tilde;
    costs =  [1000, 5000, 1000000; 1000, 5000, 1000000; 1000, 5000, 1000000];
    limits = [2 50 Inf; 2 50 Inf; 2 50 Inf]/SBASE;

    lambdaPn = costs(1,:) * SBASE;
    lambdaQn = costs(2,:) * SBASE; 
    lambdaen = costs(3,:) * SBASE;  

    delta = 0.5;

    %rng(2);

    ng_list = zeros(no_of_buses - no_of_generators, 1);
    all_buses = zeros(no_of_buses, 1);
    for i = 1:1:size(generator_data_GO,1)
        all_buses(generator_data_GO(i,1)) = -1;
    end
    count = 1;
    for i = 1:1:no_of_buses
        if(all_buses(i) == 0)
            ng_list(count) = i;
            count = count +1;
        end
    end

%----------------CLUSTERING------------------------------------------------
%[clusters, bus_to_cluster, branches_list] = createClusters(branch_data_GO, transformer_data_GO);
clusters = containers.Map('KeyType','int64','ValueType','any');
clusters(1)=[1:no_of_buses];
bus_to_cluster = ones(1,no_of_buses);
%branches_list = [1:14];
%---------------CLUSTERING ENDS HERE---------------------------------------

v = zeros(no_of_buses,1);
theta = zeros(no_of_buses,1);
pg = zeros(no_of_generators, 1);
for i = 1:1:length(cluster)
    c = cluster{i};
    for j = 1:1:length(c)
        v(c(j)) = cluster_results{i}(j);
        theta(c(j)) = cluster_results{i}(j+length(c));
    end
    generator_mapping = cluster_info(i).generator_mapping;
    for j = 1:1:size(cluster_info(i).generator_data_GO,1)
        pg(generator_mapping(j)) = cluster_results{i}(2*length(c)+j);
    end
end

d = 0.0000001;
for i = 1:1:length(pg)
    if(pg(i) > generator_data_GO(i,7)/SBASE)
        if(pg(i) - d > generator_data_GO(i,7)/SBASE)
            error('pg error');
        end
        pg(i) = generator_data_GO(i,7)/SBASE;
    elseif(pg(i) < generator_data_GO(i,8)/SBASE)
        if(pg(i) + d < generator_data_GO(i,8)/SBASE)
            error('pg minimum error');
        end
        pg(i) = generator_data_GO(i,8)/SBASE;
    end
end

generator_mapping = 1:1:no_of_generators;
qg = get_qg(v, theta, bus_info, qLi, branch_data_GO, transformer_data_GO, generator_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, SBASE);
csigma = feval(objective_function, pg, qg, v, theta, branch_data_GO, transformer_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, bus_info, pLi, qLi, gFSi, bFSi, bCSi, no_of_buses, Rbare, Sbarf, lambdaPn, lambdaQn, lambdaen, limits);
csigma
qg = get_qg(v, theta, bus_info, qLi, branch_data_GO, transformer_data_GO, generator_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, SBASE);
[~, csigma_p, csigma_q, sigmase, sigmafe] = get_excess(pg, qg, v, theta, branch_data_GO, transformer_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, bus_info, pLi, qLi, gFSi, bFSi, bCSi, no_of_buses, Rbare, Sbarf, lambdaPn, lambdaQn, lambdaen, limits);
csigma_p
csigma_q
sigmase 
sigmafe
pg_new=sum(pg)-csigma_p
cg_pg_new=get_cg(pg, linear_tables_GO, generator_mapping)
c=cg_pg_new+delta*csigma