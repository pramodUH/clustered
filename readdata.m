InFile1 = 'case.con'; %(Contingency Description Data)
InFile2 = 'case.inl'; %(Unit Inertia and Governor Response Data)
InFile3 = 'case.raw'; %(Power Flow Raw Data)
InFile4 = 'case.rop'; %(Optimal Power Flow Raw Data)

%function [generator_data_GO, fixed_bus_shunt_data_GO, branch_data_GO, transformer_data_GO, bus_data_GO, load_data_GO, case_identification_data_GO, linear_tables_GO, generator_participation_GO, contingency_data_GO, contingency_list, generator_data] = readdata(InFile1, InFile2, InFile3, InFile4)

    fileID = fopen(InFile3); % 'case.raw'

    tline = fgetl(fileID);
    case_identification_data = textscan(tline, '%f %f %f %f %f %f', 'Delimiter', ',');
    case_identification_data = cell2mat(case_identification_data);
    case_identification_data_GO = case_identification_data(:,2);

    tline = fgetl(fileID);
    tline = fgetl(fileID);

    busdata_temp = struct('data', []);
    loaddata_temp = struct('data', []);
    shuntdata_temp = struct('data', []);
    generatordata_temp = struct('data', []);
    branchdata_temp = struct('data', []);
    transformerdata_temp = struct('data', []);
    switchedshuntdata_temp = struct('data', []);

    generatordispatch_temp = struct('data', []);
    activepowerdispatch_temp = struct('data', []);
    linearcost_temp = struct('data', []);


    bus_count = 0;
    load_count = 0;
    shunt_count = 0;
    generator_count = 0;
    branch_count = 0;
    switched_shunt_count = 0;

    generator_dispatch_count = 0;
    active_power_dispatch_count = 0;

    tline = fgetl(fileID);

    while(~identify_end(tline))
        bus_count = bus_count + 1;
        busdata_temp(bus_count).data = tline;
        tline = fgetl(fileID);
    end
    
    bus_data = textscan(busdata_temp(1).data, '%f  %s %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
    bus_data_mapping(bus_data{1}) = 1;
    
    for i=2:1:bus_count
        bus_temp = textscan(busdata_temp(i).data, '%f %s %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
        bus_data(i,:) = bus_temp;
        bus_data_mapping(bus_temp{1}) = i;
    end
    bus_data_GO = [cell2mat(bus_data(:,1)), cell2mat(bus_data(:,5)), cell2mat(bus_data(:,8)), cell2mat(bus_data(:,9)), cell2mat(bus_data(:,10)), cell2mat(bus_data(:,11)), cell2mat(bus_data(:,12)), cell2mat(bus_data(:,13))];
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        load_count = load_count + 1;
        loaddata_temp(load_count).data = tline;
        tline = fgetl(fileID);
    end
    load_data = textscan(loaddata_temp(1).data, '%f %s %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
    for i=2:1:load_count
        load_data(i,:) = textscan(loaddata_temp(i).data, '%f %s %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
    end
    
    load_data_GO = [cell2mat(load_data(:,1)), cell2mat(load_data(:,3)), cell2mat(load_data(:,6)), cell2mat(load_data(:,7))]; 
    for i = 1:1:size(load_data_GO,1)
        bus_number = load_data_GO(i,1);
        bus_index = bus_data_mapping(bus_number);
        load_data_GO(i,1) = bus_index;
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        shunt_count = shunt_count + 1;
        shuntdata_temp(shunt_count).data = tline;
        tline = fgetl(fileID);
    end
    
    if(shunt_count ~= 0)
        fixed_bus_shunt_data = textscan(shuntdata_temp(1).data, '%f %s %f %f %f', 'Delimiter', ',');
        for i=2:1:shunt_count
            fixed_bus_shunt_data(i,:) = textscan(shuntdata_temp(i).data, '%f %s %f %f %f', 'Delimiter', ',');
        end
        fixed_bus_shunt_data_GO = [cell2mat(fixed_bus_shunt_data(:,1)), cell2mat(fixed_bus_shunt_data(:,3)), cell2mat(fixed_bus_shunt_data(:,4)), cell2mat(fixed_bus_shunt_data(:,5))];
        for i = 1:1:size(fixed_bus_shunt_data_GO,1)
            bus_number = fixed_bus_shunt_data_GO(i,1);
            bus_index = bus_data_mapping(bus_number);
            fixed_bus_shunt_data_GO(i,1) = bus_index;
        end
    else
        fixed_bus_shunt_data_GO = [];
    end
    tline = fgetl(fileID);
    while(~identify_end(tline))
        generator_count = generator_count + 1;
        generatordata_temp(generator_count).data = tline;
        tline = fgetl(fileID);
    end
   
    generator_data = textscan(generatordata_temp(1).data, '%f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
    generator_bus = generator_data{1};
    generator_name = generator_data{2}(1,1);
    generator_name = generator_name{1};
    generator_name = strtok(strtok(strtok(generator_name,''''),''''));
    generator_id = sprintf('%d_%s', generator_bus, generator_name);
    generator_mapping = containers.Map(generator_id, 1);
    for i=2:1:generator_count
        g_temp = textscan(generatordata_temp(i).data, '%f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
        generator_data(i,:) = g_temp;
        generator_bus = g_temp{1};
        generator_name = g_temp{2}(1,1);
        generator_name = generator_name{1};
        generator_name = strtok(strtok(strtok(generator_name,''''),''''));
        generator_id = sprintf('%d_%s', generator_bus, generator_name);
        generator_mapping(generator_id) =  i;        
    end
    generator_data_GO = [cell2mat(generator_data(:,1)), cell2mat(generator_data(:,3)), cell2mat(generator_data(:,4)), cell2mat(generator_data(:,5)),cell2mat(generator_data(:,6)),cell2mat(generator_data(:,15)),cell2mat(generator_data(:,17)),cell2mat(generator_data(:,18))];
    for i = 1:1:size(generator_data_GO,1)
        generator_bus = generator_data_GO(i,1);
        generator_index = bus_data_mapping(generator_bus);
        generator_data_GO(i,1) = generator_index;
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        branch_count = branch_count + 1;
        branchdata_temp(branch_count).data = tline;
        tline = fgetl(fileID);
    end
    
    
    branch_data = textscan(branchdata_temp(1).data, '%f %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
    branch_bus_origin = branch_data{1};
    branch_bus_destination = branch_data{2};
    circuit_name = branch_data{3}(1,1);
    circuit_name = circuit_name{1};
    circuit_name = strtok(strtok(strtok(circuit_name,''''),''''));
    branch_id = sprintf('%d_%d_%s', branch_bus_origin, branch_bus_destination, circuit_name);
    branch_mapping = containers.Map(branch_id, 1);
    
    for i=2:1:branch_count
        b_temp = textscan(branchdata_temp(i).data, '%f %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', 'Delimiter', ',');
        branch_data(i,:) = b_temp;
        branch_bus_origin = b_temp{1};
        branch_bus_destination = b_temp{2};
        circuit_name = b_temp{3}(1,1);
        circuit_name = circuit_name{1};
        circuit_name = strtok(strtok(strtok(circuit_name,''''),''''));
        branch_id = sprintf('%d_%d_%s', branch_bus_origin, branch_bus_destination, circuit_name);
        branch_mapping(branch_id) =  i;        
    end
    branch_data_GO = [cell2mat(branch_data(:,1)), cell2mat(branch_data(:,2)), cell2mat(branch_data(:,4)), cell2mat(branch_data(:,5)), cell2mat(branch_data(:,6)), cell2mat(branch_data(:,7)), cell2mat(branch_data(:,9)), cell2mat(branch_data(:,14))];
    for i = 1:1:size(branch_data_GO,1)
        start_bus = branch_data_GO(i,1);
        start_index = bus_data_mapping(start_bus);
        end_bus = branch_data_GO(i,2);
        end_index = bus_data_mapping(end_bus);
        branch_data_GO(i,1) = start_index;
        branch_data_GO(i,2) = end_index;
    end
    
    tline = fgetl(fileID);
    tline2 = fgetl(fileID);
    tline3 = fgetl(fileID);
    tline4 = fgetl(fileID);
    string = strcat(tline, ',', tline2, ',', tline3, ',', tline4);
    transformerdata_temp.data = string;

    transformer_count = 1;
    tline = fgetl(fileID);
    while(~identify_end(tline))
        transformer_count = transformer_count + 1;
        tline2 = fgetl(fileID);
        tline3 = fgetl(fileID);
        tline4 = fgetl(fileID);
        string = strcat(tline, ',', tline2, ',', tline3, ',', tline4);
        transformerdata_temp(transformer_count).data = string;
        tline = fgetl(fileID);
    end
    
    transformer_data = textscan(transformerdata_temp(1).data, '%f %f %f %s %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f  %f %f %f', 'Delimiter', ',');
    transformer_bus_origin = transformer_data{1};
    transformer_bus_destination = transformer_data{2};
    transformer_name = transformer_data{4}(1,1);
    transformer_name = transformer_name{1};
    transformer_name = strtok(strtok(strtok(transformer_name,''''),''''));
    transformer_id = sprintf('%d_%d_%s', transformer_bus_origin, transformer_bus_destination, transformer_name);
    transformer_mapping = containers.Map(transformer_id, 1);
    for i = 2:1:transformer_count
        t_temp = textscan(transformerdata_temp(i).data, '%f %f %f %s %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f  %f %f %f', 'Delimiter', ',');
        transformer_data(i,:) = t_temp;
        transformer_bus_origin = t_temp{1};
        transformer_bus_destination = t_temp{2};
        transformer_name = t_temp{4}(1,1);
        transformer_name = transformer_name{1};
        transformer_name = strtok(strtok(strtok(transformer_name,''''),''''));
        transformer_id = sprintf('%d_%d_%s', transformer_bus_origin, transformer_bus_destination, transformer_name);
        transformer_mapping(transformer_id) =  i;        
    end

    transformer_data_GO = [cell2mat(transformer_data(:,1)), cell2mat(transformer_data(:,2)), cell2mat(transformer_data(:,8)), cell2mat(transformer_data(:,9)), cell2mat(transformer_data(:,12)), cell2mat(transformer_data(:,22)), cell2mat(transformer_data(:,23)), cell2mat(transformer_data(:,25)), cell2mat(transformer_data(:,27)), cell2mat(transformer_data(:,28)), cell2mat(transformer_data(:,30)), cell2mat(transformer_data(:,42))];
    for i = 1:1:size(transformer_data_GO,1)
        start_bus = transformer_data_GO(i,1);
        start_index = bus_data_mapping(start_bus);
        end_bus = transformer_data_GO(i,2);
        end_index = bus_data_mapping(end_bus);
        transformer_data_GO(i,1) = start_index;
        transformer_data_GO(i,2) = end_index;
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end   
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    
    tline = fgetl(fileID);
    while(~identify_end(tline))
        switched_shunt_count = switched_shunt_count + 1;
        switchedshuntdata_temp(switched_shunt_count).data = tline;
        tline = fgetl(fileID);
    end
    
    if(switched_shunt_count ~=0)
        switched_shunt_data = textscan(switchedshuntdata_temp(1).data, '%f %f %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','Delimiter',',');
    
        for i = 1:1:switched_shunt_count
            switched_shunt_data(i,:) = textscan(switchedshuntdata_temp(i).data, '%f %f %f %f %f %f %f %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','Delimiter',',');
        end
    
        switched_shunt_data_GO = [cell2mat(switched_shunt_data(:,1)), cell2mat(switched_shunt_data(:,4)), cell2mat(switched_shunt_data(:,10)), cell2mat(switched_shunt_data(:,11)), cell2mat(switched_shunt_data(:,12)), cell2mat(switched_shunt_data(:,13)), cell2mat(switched_shunt_data(:,14)), cell2mat(switched_shunt_data(:,15)), cell2mat(switched_shunt_data(:,16)), cell2mat(switched_shunt_data(:,17)), cell2mat(switched_shunt_data(:,18)), cell2mat(switched_shunt_data(:,19)), cell2mat(switched_shunt_data(:,20)), cell2mat(switched_shunt_data(:,21)), cell2mat(switched_shunt_data(:,22)), cell2mat(switched_shunt_data(:,23)), cell2mat(switched_shunt_data(:,24)), cell2mat(switched_shunt_data(:,25)), cell2mat(switched_shunt_data(:,26))];   
    else
        switched_shunt_data_GO = [];
    end
    for i = 1:1:size(switched_shunt_data_GO,1)
        shunt_bus = switched_shunt_data_GO(i,1);
        shunt_index = bus_data_mapping(shunt_bus);
        switched_shunt_data_GO(i,1) = shunt_index;
    end
    
    fclose(fileID);

    fileID = fopen(InFile4); % 'case.rop'
 
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end

    tline = fgetl(fileID);

    while(~identify_end(tline))
        generator_dispatch_count = generator_dispatch_count +1;
        generatordispatch_temp(generator_dispatch_count).data = tline;
        tline = fgetl(fileID);
    end

    generator_dispatch = textscan(generatordispatch_temp(1).data, '%f %s %f %f', 'Delimiter', ',');
    bus_index = generator_dispatch{1};
    generator_id = strtok(strtok(strtok(generator_dispatch{2},''''),''''));
    gen = sprintf('%d_%s', bus_index, generator_id{1});
    generator_index = generator_mapping(gen);
    generator_table = containers.Map(generator_dispatch{4}, generator_index);
    
    for i=1:1:generator_dispatch_count
        generator_dispatch = textscan(generatordispatch_temp(i).data, '%f %s %f %f', 'Delimiter', ',');
        bus_index = generator_dispatch{1};
        generator_id = strtok(strtok(strtok(generator_dispatch{2},''''),''''));
        gen = sprintf('%d_%s', bus_index, generator_id{1});
        generator_index = generator_mapping(gen);
        generator_table(generator_dispatch{4}) = generator_index;
        
    end
   
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    tline = fgetl(fileID);
    while(~identify_end(tline))
        tline = fgetl(fileID);
    end
    
    tline = fgetl(fileID);
    values = textscan(tline, '%f %s %f', 'Delimiter', ',');
    table_no = values{1};
    gen_no = generator_table(table_no);
    no_of_lines = values{3};
    tline = fgetl(fileID);
    linear_table = textscan(tline, '%f %f', 'Delimiter', ',');
    for i=2:1:no_of_lines
        tline = fgetl(fileID);
        linear_table(i,:) = textscan(tline, '%f %f', 'Delimiter', ','); 
    end
    linear_tables{gen_no} = cell2mat(linear_table);

    tline = fgetl(fileID);
    while(~identify_end(tline))
        values = textscan(tline, '%f %s %f', 'Delimiter', ',');
        table_no = values{1};
        gen_no = generator_table(table_no);
        no_of_lines = values{3};
        tline = fgetl(fileID);
        linear_table = textscan(tline, '%f %f', 'Delimiter', ',');
        for i = 2:1:no_of_lines
            tline = fgetl(fileID);
            linear_table(i,:) = textscan(tline, '%f %f', 'Delimiter', ',');
        end
        linear_tables{gen_no} = cell2mat(linear_table);
        tline = fgetl(fileID);
    end
    fclose(fileID);

    fileID = fopen(InFile2); % 'case.inl'
    tline = fgetl(fileID);
    generator_participation = textscan(tline, '%f %s %f %f %f %f %f', 'Delimiter', ',');
    count = 2;
    tline = fgetl(fileID);
    while(~identify_end(tline))
        generator_participation(count,:) = textscan(tline, '%f %s %f %f %f %f %f', 'Delimiter', ',');
        count = count + 1;
        tline = fgetl(fileID);
    end
    generator_participation_GO = [cell2mat(generator_participation(:,1)), cell2mat(generator_participation(:,6))];  
    fclose(fileID);

    
    fileID = fopen(InFile1);
    tline = fgetl(fileID);
    [word,rem] = strtok(tline);
    name = strtok(rem);
    count = 1;
    contingency_data_GO = zeros(1,3);
    contingency_list = {};
    while(~strcmp(word, 'END'))
        contingency_list{count} = name;
        tline = fgetl(fileID);
        contingency = textscan(tline, '%s %s %s %s %f %s %s %f %s %s');
        if(strcmp(contingency{2},'BRANCH'))
            contingency_data_GO(count,1) = 0;
            start = contingency{5};
            finish = contingency{8};
            contingency_data_GO(count,2) = start;
            contingency_data_GO(count,3) = finish;
            count = count +1;
        end
        fgetl(fileID);
        tline = fgetl(fileID);
        words = textscan(tline, '%s %s');
        word = words{1};
        name = words{2};
    end
    fclose(fileID);
    
    system_loads = zeros(size(bus_data_GO,1),2);
    for i=1:1:size(load_data_GO,1)
        system_loads(load_data_GO(i),1) = bus_data_GO(i,3);
        system_loads(load_data_GO(i),2) = bus_data_GO(i,4);
    end
    linear_tables_GO = linear_tables;
clear rem