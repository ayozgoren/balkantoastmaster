function RunToastMachine()
    % 1. Initialize
    Logic = ToastLogic();
    Theme = ToastConfig.getTheme();
    Products = ToastConfig.getProducts();
    Coins = ToastConfig.getCoins();
    ProcessFiles = ToastConfig.getProcessImages();
    AudioFiles = ToastConfig.getAudioFiles();
    
    % 2. Main Window
    fig = uifigure('Name', 'Balkan Toast Master', ...
        'Position', [100 100 850 650], ... 
        'Color', Theme.Background);

    % --- RIGHT SIDE: DETAIL PANEL ---
    % Position: [x, y, w, h]
    pnlPreview = uipanel(fig, 'Position', [500 420 300 200], ...
        'BackgroundColor', '#7c94f7');
    
    avatarSource = '';
    if exist('toast_avatar.png', 'file'), avatarSource = 'toast_avatar.png'; end
    
    imgAvatar = uiimage(pnlPreview, 'Position', [25 25 250 150], ...
        'ImageSource', avatarSource, 'ScaleMethod', 'fit', 'AltText', 'No Product Selected');
        
    lblStatus = uilabel(pnlPreview, 'Position', [10 5 280 20], ...
        'Text', 'Select a product!', 'FontColor', 'white', ...
        'HorizontalAlignment', 'center');

    % --- LEFT SIDE: PRODUCTS ---
    for i = 1:length(Products)
        p = Products(i);
        col = 1 + mod(i-1, 2); 
        row = ceil(i/2);       
        x = 30 + (col-1)*220; 
        y = 570 - (row-1)*70; 
        ToastComponents.createProductBtn(fig, x, y, p, @(btn,e) selectItemCallback(p));
    end

    % --- BOTTOM LEFT: PROCESS IMAGE ---
    pnlFrame = uipanel(fig, 'Position', [30 180 420 230], ...
        'BackgroundColor', [0.5 0.5 0.5]);
    
    imgSource = ''; 
    if exist(ProcessFiles.Idle, 'file'), imgSource = ProcessFiles.Idle; end

    imgProcess = uiimage(pnlFrame, 'Position', [10 10 400 210], ...
        'ImageSource', imgSource, 'ScaleMethod', 'stretch', 'AltText', 'Process View');

    % --- BOTTOM LEFT: COINS ---
    for k = 1:length(Coins)
        val = Coins(k);
        x = 30 + (k-1)*65;
        ToastComponents.createCoinBtn(fig, x, 80, val, @(src,e) coinInsertedCallback(val));
    end

    % --- RIGHT SIDE: CONTROLS ---
    btnConfirm = uibutton(fig, 'Position', [600 360 120 40], ...
        'Text', 'Confirm', 'BackgroundColor', Theme.ConfirmGreen, ...
        'FontColor', 'white', 'FontSize', 14, 'FontWeight', 'bold', ...
        'ButtonPushedFcn', @confirmCallback);
        
    lamp = uilamp(fig, 'Position', [740 370 20 20], 'Color', [0.2 0.4 0.2]);

    createLabel(fig, [500 290 80 30], 'Spice'); 
    createLabel(fig, [500 230 80 30], 'Money');
    createLabel(fig, [500 170 80 30], 'Change');
    
    dispSpice   = ToastComponents.createDarkPanel(fig, [640 290 50 30]);
    dispMoney   = ToastComponents.createDarkPanel(fig, [600 230 80 30]);
    dispChange  = ToastComponents.createDarkPanel(fig, [600 170 80 30]);
    
    uibutton(fig, 'Position', [600 290 30 30], 'Text', '-', ...
        'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'white', ...
        'ButtonPushedFcn', @(s,e) spiceCallback(-1));
        
    uibutton(fig, 'Position', [700 290 30 30], 'Text', '+', ...
        'BackgroundColor', [0.2 0.2 0.2], 'FontColor', 'white', ...
        'ButtonPushedFcn', @(s,e) spiceCallback(1));

    uibutton(fig, 'Position', [600 120 80 30], ...
        'Text', 'Take Change', ...
        'BackgroundColor', Theme.Button, ...
        'FontColor', 'white', ...
        'ButtonPushedFcn', @takeChangeCallback);


    % --- CALLBACKS ---
    function selectItemCallback(product)
        Logic.setProduct(product);
        lblStatus.Text = product.Name;
        lblStatus.FontColor = 'cyan';
        lamp.Color = 'yellow';
        
        if exist(product.DetailImageFile, 'file')
            imgAvatar.ImageSource = product.DetailImageFile;
        else
            if exist('toast_avatar.png', 'file')
                imgAvatar.ImageSource = 'toast_avatar.png';
            else
                 imgAvatar.ImageSource = '';
            end
        end
    end

    function coinInsertedCallback(val)
        Logic.addMoney(val);
        dispMoney.Text = sprintf('%.2f', Logic.CurrentCredit);
        if ~isempty(Logic.SelectedProduct) && Logic.CurrentCredit >= Logic.SelectedProduct.Price
            lamp.Color = 'green';
        end
    end

    function spiceCallback(delta)
        Logic.changeSpice(delta);
        dispSpice.Text = num2str(Logic.SpiceCount);
    end

    function takeChangeCallback(~, ~)
        Logic.CurrentCredit = 0;
        Logic.SelectedProduct = []; 
        Logic.SpiceCount = 0;
        
        dispMoney.Text = '0.00';
        dispChange.Text = '0.00';
        dispSpice.Text = '0';
        lamp.Color = [0.2 0.4 0.2]; 
        lblStatus.Text = 'Select a product!';
        
        if exist('toast_avatar.png', 'file')
            imgAvatar.ImageSource = 'toast_avatar.png';
        else
            imgAvatar.ImageSource = '';
        end
    end

    function confirmCallback(~, ~)
        currentID = 0;
        if ~isempty(Logic.SelectedProduct)
            currentID = Logic.SelectedProduct.ID;
        end

        [success, msg, change] = Logic.tryPurchase();
        
        if success
            btnConfirm.Enable = 'off';
            lblStatus.Text = 'Preparing...';
            lamp.Color = 'green';
            
            soundDuration = 1.5;
            
            % Toasts (ID 1, 2, 3) -> Play Cook Sound + Show Image
            if currentID >= 1 && currentID <= 3
                if exist(ProcessFiles.Active, 'file')
                    imgProcess.ImageSource = ProcessFiles.Active;
                end
                soundDuration = ToastAudio.playAndWait(AudioFiles.Cook);
            
            % Drinks (ID 4, 5, 6) -> Play Fill Sound
            elseif currentID >= 4 && currentID <= 6
                soundDuration = ToastAudio.playAndWait(AudioFiles.Fill);
            end
            
            pause(soundDuration); 
            
            % Reset Process Image
            if exist(ProcessFiles.Idle, 'file')
                imgProcess.ImageSource = ProcessFiles.Idle;
            end
            
            dispChange.Text = sprintf('%.2f', change);
            lblStatus.Text = msg;
            dispMoney.Text = '0.00';
            dispSpice.Text = '0';
            btnConfirm.Enable = 'on';
            
            % Reset Detail Image
            if exist('toast_avatar.png', 'file')
                imgAvatar.ImageSource = 'toast_avatar.png';
            else
                imgAvatar.ImageSource = '';
            end
            
        else
            uialert(fig, msg, 'Transaction Error');
            lamp.Color = 'red';
        end
    end

    function createLabel(p, pos, txt)
        uilabel(p, 'Position', pos, 'Text', txt, ...
            'FontColor', 'white', 'FontSize', 12, 'FontWeight', 'bold');
    end
end