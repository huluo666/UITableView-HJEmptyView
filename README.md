# UITableView-HJEmptyView
###利用Runtime一行代码实现UITableView的空视图EmptyView显示,省去没必要的判断和几行代码即可快速自定义精美的空视图显示。

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];//添加表格视图
    
    [self setUpEmptyView];//设置空视图
}

```

###NO.1 使用默认空视图
```objc
-(void)setUpEmptyView
{
   self.emptyView=[HJEmptyView defaultEmptyView];
}
  
```


###NO.2 使用自定义空视图
```objc
-(void)setUpEmptyView
{
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    //自定义空视图
    HJEmptyView  *emptyView=[HJEmptyView showTitle:@"oh,shit!!!" details:@"对不起,没有网络\n请检查网络网络是否打开" iconImag:@"no-wifi" toView:self.view];
    
    self.emptyView=emptyView;
    //点击刷新按钮
    emptyView.refreshBtnClickBlock=^(UIButton *button){
        [weakSelf MJBeginRefreshing];
    };
    
    
    //轻击Empty视图回调
    emptyView.refreshEmptyTapBlock=^(UIView *view){
        [weakSelf MJBeginRefreshing];
    };
    
    self.tableView.nxEV_emptyView=self.emptyView;
}
```

