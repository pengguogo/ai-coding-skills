# 设计模式示例（Java / Kotlin）

> **唯一职责**：常用模式的**对照示例代码**。不含执行原则、不含命名表、不重复架构条文。
> 约束与简单优先原则见 [android-coding-standard.md](android-coding-standard.md)。**仅当** task 需要实现对应模式时打开本章相关节。

## 模式索引

| 模式 | Android 场景 |
|------|----------------|
| [MVVM](#mvvm) | UI 与业务分离，ViewModel 持有状态 |
| [Repository](#repository) | 单一数据源，合并本地/远程 |
| [Use Case](#use-case) | 可复用业务规则 |
| [Observer](#observer) | LiveData / Flow 驱动 UI |
| [UDF + UI State](#udf--ui-state) | 单向数据流、不可变状态 |
| [Adapter](#adapter) | RecyclerView 列表 |
| [Factory](#factory) | 按类型创建 Fragment / ViewModel 依赖 |
| [Builder](#builder) | 复杂不可变配置对象 |
| [Strategy](#strategy) | 可替换算法（排序、定价、校验） |
| [Mapper](#mapper) | DTO ↔ 领域模型 |
| [Singleton](#singleton) | 进程内单例（慎用，优先 DI） |

---

## MVVM

**意图**：View 只渲染状态、转发事件；ViewModel 在配置变更后存活。

### Java

```java
// feature.profile.ui.ProfileFragment.java
public class ProfileFragment extends Fragment {
    private FragmentProfileBinding binding;
    private ProfileViewModel viewModel;

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        viewModel = new ViewModelProvider(this).get(ProfileViewModel.class);
        binding = FragmentProfileBinding.bind(view);
        viewModel.getUiState().observe(getViewLifecycleOwner(), state -> render(state));
        binding.btnRefresh.setOnClickListener(v -> viewModel.refresh());
    }

    private void render(ProfileUiState state) {
        binding.progress.setVisibility(state.isLoading ? View.VISIBLE : View.GONE);
        binding.tvName.setText(state.displayName);
    }
}

// feature.profile.viewmodel.ProfileViewModel.java
public class ProfileViewModel extends ViewModel {
    private final UserRepository repository;
    private final MutableLiveData<ProfileUiState> uiState =
            new MutableLiveData<>(ProfileUiState.initial());

    public ProfileViewModel(UserRepository repository) {
        this.repository = repository;
    }

    public LiveData<ProfileUiState> getUiState() {
        return uiState;
    }

    public void refresh() {
        uiState.setValue(ProfileUiState.loading());
        repository.getProfile(new Callback<Profile>() {
            @Override
            public void onSuccess(Profile profile) {
                uiState.setValue(ProfileUiState.success(profile.getDisplayName()));
            }
            @Override
            public void onError(Throwable t) {
                uiState.setValue(ProfileUiState.error(t.getMessage()));
            }
        });
    }
}
```

### Kotlin

```kotlin
// ProfileScreen.kt — Compose
@Composable
fun ProfileRoute(viewModel: ProfileViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    ProfileScreen(
        uiState = uiState,
        onRefresh = viewModel::refresh,
    )
}

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val repository: UserRepository,
) : ViewModel() {
    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    fun refresh() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            repository.getProfile()
                .onSuccess { p -> _uiState.update { it.copy(isLoading = false, displayName = p.name) } }
                .onFailure { e -> _uiState.update { it.copy(isLoading = false, error = e.message) } }
        }
    }
}
```

---

## Repository

**意图**：对上层隐藏数据来源；缓存与网络冲突在此解决。

### Java

```java
public class UserRepository {
    private final UserApi api;
    private final UserDao dao;

    public UserRepository(UserApi api, UserDao dao) {
        this.api = api;
        this.dao = dao;
    }

    public LiveData<User> observeUser(String id) {
        return Transformations.map(dao.observeById(id), EntityMapper::toDomain);
    }

    public void refreshUser(String id, Callback<User> callback) {
        api.fetchUser(id).enqueue(new Callback<UserDto>() {
            @Override
            public void onResponse(Call<UserDto> call, Response<UserDto> response) {
                if (response.isSuccessful() && response.body() != null) {
                    dao.upsert(EntityMapper.toEntity(response.body()));
                    callback.onSuccess(EntityMapper.toDomain(response.body()));
                } else {
                    callback.onError(new IOException("fetch failed"));
                }
            }
            @Override
            public void onFailure(Call<UserDto> call, Throwable t) {
                callback.onError(t);
            }
        });
    }
}
```

### Kotlin

```kotlin
class UserRepository @Inject constructor(
    private val api: UserApi,
    private val dao: UserDao,
) {
    fun observeUser(id: String): Flow<User> =
        dao.observeById(id).map { it.toDomain() }

    suspend fun refreshUser(id: String): Result<User> = runCatching {
        val dto = api.fetchUser(id)
        dao.upsert(dto.toEntity())
        dto.toDomain()
    }
}
```

---

## Use Case

**意图**：封装单一业务能力，供多个 ViewModel 复用。

### Java

```java
public class GetUserProfileUseCase {
    private final UserRepository repository;

    public GetUserProfileUseCase(UserRepository repository) {
        this.repository = repository;
    }

    public void execute(String userId, Callback<Profile> callback) {
        repository.refreshUser(userId, new Callback<User>() {
            @Override
            public void onSuccess(User user) {
                callback.onSuccess(new Profile(user.getId(), user.getDisplayName()));
            }
            @Override
            public void onError(Throwable t) {
                callback.onError(t);
            }
        });
    }
}
```

### Kotlin

```kotlin
class GetUserProfileUseCase @Inject constructor(
    private val repository: UserRepository,
) {
    suspend operator fun invoke(userId: String): Result<Profile> =
        repository.refreshUser(userId).map { Profile(it.id, it.displayName) }
}
```

---

## Observer

**意图**：数据变化自动通知 UI；Fragment 用 `viewLifecycleOwner`。

### Java — LiveData

```java
// ViewModel
private final MutableLiveData<List<Item>> items = new MutableLiveData<>();
public LiveData<List<Item>> getItems() { return items; }

// Fragment
viewModel.getItems().observe(getViewLifecycleOwner(), list -> adapter.submitList(list));
```

### Kotlin — Flow

```kotlin
// ViewModel
val items: StateFlow<List<Item>> = repository.observeItems()
    .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptyList())

// Fragment
viewLifecycleOwner.lifecycleScope.launch {
    viewLifecycleOwner.repeatOnLifecycle(Lifecycle.State.STARTED) {
        viewModel.items.collect { adapter.submitList(it) }
    }
}
```

---

## UDF + UI State

**意图**：状态只向下流；事件只向上传递；UI State 不可变。

### Java

```java
public final class CartUiState {
    public final List<CartItem> items;
    public final boolean isLoading;
    public final String errorMessage;

    private CartUiState(List<CartItem> items, boolean isLoading, String errorMessage) {
        this.items = items;
        this.isLoading = isLoading;
        this.errorMessage = errorMessage;
    }

    public static CartUiState loading() {
        return new CartUiState(Collections.emptyList(), true, null);
    }

    public CartUiState withItems(List<CartItem> items) {
        return new CartUiState(items, false, null);
    }
}

// ViewModel：仅通过新方法产生新状态
public void addItem(CartItem item) {
    CartUiState current = uiState.getValue();
    if (current == null) return;
    List<CartItem> next = new ArrayList<>(current.items);
    next.add(item);
    uiState.setValue(current.withItems(next));
}
```

### Kotlin

```kotlin
data class CartUiState(
    val items: List<CartItem> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
)

// 事件向上
sealed interface CartEvent {
    data class AddItem(val item: CartItem) : CartEvent
    data object Checkout : CartEvent
}

fun onEvent(event: CartEvent) {
    when (event) {
        is CartEvent.AddItem -> _uiState.update {
            it.copy(items = it.items + event.item)
        }
        CartEvent.Checkout -> checkout()
    }
}
```

---

## Adapter

**意图**：列表项展示与交互；配合 DiffUtil 避免全量刷新。

### Java

```java
public class ItemAdapter extends ListAdapter<Item, ItemAdapter.VH> {
    private final OnItemClickListener listener;

    public ItemAdapter(OnItemClickListener listener) {
        super(DIFF);
        this.listener = listener;
    }

    private static final DiffUtil.ItemCallback<Item> DIFF = new DiffUtil.ItemCallback<Item>() {
        @Override
        public boolean areItemsTheSame(@NonNull Item oldItem, @NonNull Item newItem) {
            return oldItem.getId().equals(newItem.getId());
        }
        @Override
        public boolean areContentsTheSame(@NonNull Item oldItem, @NonNull Item newItem) {
            return oldItem.equals(newItem);
        }
    };

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        ItemRowBinding binding = ItemRowBinding.inflate(
                LayoutInflater.from(parent.getContext()), parent, false);
        return new VH(binding);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        Item item = getItem(position);
        holder.binding.tvTitle.setText(item.getTitle());
        holder.binding.getRoot().setOnClickListener(v -> listener.onClick(item));
    }

    static class VH extends RecyclerView.ViewHolder {
        final ItemRowBinding binding;
        VH(ItemRowBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }
    }

    interface OnItemClickListener {
        void onClick(Item item);
    }
}
```

### Kotlin

```kotlin
class ItemAdapter(
    private val onClick: (Item) -> Unit,
) : ListAdapter<Item, ItemAdapter.VH>(DIFF) {

    object DIFF : DiffUtil.ItemCallback<Item>() {
        override fun areItemsTheSame(a: Item, b: Item) = a.id == b.id
        override fun areContentsTheSame(a: Item, b: Item) = a == b
    }

    class VH(val binding: ItemRowBinding) : RecyclerView.ViewHolder(binding.root)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
        VH(ItemRowBinding.inflate(LayoutInflater.from(parent.context), parent, false))

    override fun onBindViewHolder(holder: VH, position: Int) {
        val item = getItem(position)
        holder.binding.tvTitle.text = item.title
        holder.binding.root.setOnClickListener { onClick(item) }
    }
}
```

---

## Factory

**意图**：集中创建对象，隐藏构造细节（Fragment、解析器、ViewModel 依赖树由 Hilt 负责时优先 DI）。

### Java

```java
public final class FragmentFactory {
    private FragmentFactory() {}

    public static Fragment newProductDetail(String productId) {
        ProductDetailFragment fragment = new ProductDetailFragment();
        Bundle args = new Bundle();
        args.putString(ProductDetailFragment.ARG_PRODUCT_ID, productId);
        fragment.setArguments(args);
        return fragment;
    }
}
```

### Kotlin

```kotlin
object FragmentFactory {
    fun newProductDetail(productId: String): ProductDetailFragment =
        ProductDetailFragment().apply {
            arguments = bundleOf(ProductDetailFragment.ARG_PRODUCT_ID to productId)
        }
}

// 或使用 sealed class 表达导航目的地
sealed class Destination {
    data class ProductDetail(val productId: String) : Destination()
    data object Cart : Destination()
}
```

---

## Builder

**意图**：多可选参数的可读构造；Android 中常用于请求配置、Notification、复杂 Domain 对象。

### Java

```java
public final class SearchRequest {
    public final String query;
    public final int page;
    public final String sortBy;

    private SearchRequest(Builder builder) {
        this.query = builder.query;
        this.page = builder.page;
        this.sortBy = builder.sortBy;
    }

    public static Builder builder(String query) {
        return new Builder(query);
    }

    public static final class Builder {
        private final String query;
        private int page = 0;
        private String sortBy = "relevance";

        private Builder(String query) {
            this.query = query;
        }

        public Builder page(int page) {
            this.page = page;
            return this;
        }

        public Builder sortBy(String sortBy) {
            this.sortBy = sortBy;
            return this;
        }

        public SearchRequest build() {
            return new SearchRequest(this);
        }
    }
}

// 使用
SearchRequest req = SearchRequest.builder("phone").page(1).sortBy("price").build();
```

### Kotlin

```kotlin
data class SearchRequest(
    val query: String,
    val page: Int = 0,
    val sortBy: String = "relevance",
)

// 命名参数即 Builder
val req = SearchRequest(query = "phone", page = 1, sortBy = "price")

// 需要校验时用 apply DSL
fun searchRequest(query: String, block: SearchRequestBuilder.() -> Unit): SearchRequest =
    SearchRequestBuilder(query).apply(block).build()

class SearchRequestBuilder(private val query: String) {
    var page: Int = 0
    var sortBy: String = "relevance"
    fun build() = SearchRequest(query, page, sortBy)
}
```

---

## Strategy

**意图**：运行时替换算法，避免大量 `if-else`。

### Java

```java
public interface PriceStrategy {
    BigDecimal calculate(BigDecimal base);
}

public class MemberPriceStrategy implements PriceStrategy {
    @Override
    public BigDecimal calculate(BigDecimal base) {
        return base.multiply(new BigDecimal("0.9"));
    }
}

public class CartViewModel extends ViewModel {
    private PriceStrategy priceStrategy = new MemberPriceStrategy();

    public void setPriceStrategy(PriceStrategy strategy) {
        this.priceStrategy = strategy;
    }

    BigDecimal total(List<LineItem> items) {
        BigDecimal sum = BigDecimal.ZERO;
        for (LineItem item : items) {
            sum = sum.add(priceStrategy.calculate(item.getPrice()));
        }
        return sum;
    }
}
```

### Kotlin

```kotlin
fun interface PriceStrategy {
    fun calculate(base: BigDecimal): BigDecimal
}

val memberStrategy = PriceStrategy { base -> base * BigDecimal("0.9") }

class CartViewModel : ViewModel() {
    private var priceStrategy: PriceStrategy = memberStrategy

    fun setPriceStrategy(strategy: PriceStrategy) {
        priceStrategy = strategy
    }

    fun total(items: List<LineItem>): BigDecimal =
        items.fold(BigDecimal.ZERO) { acc, item ->
            acc + priceStrategy.calculate(item.price)
        }
}
```

---

## Mapper

**意图**：隔离网络/数据库模型与 UI/领域模型。

### Java

```java
public final class UserMapper {
    private UserMapper() {}

    public static User toDomain(UserDto dto) {
        return new User(dto.id, dto.displayName);
    }

    public static UserEntity toEntity(UserDto dto) {
        return new UserEntity(dto.id, dto.displayName, System.currentTimeMillis());
    }

    public static User toDomain(UserEntity entity) {
        return new User(entity.id, entity.displayName);
    }
}
```

### Kotlin

```kotlin
// UserMappers.kt
fun UserDto.toDomain() = User(id, displayName)
fun UserDto.toEntity() = UserEntity(id, displayName, updatedAt = System.currentTimeMillis())
fun UserEntity.toDomain() = User(id, displayName)
```

---

## Singleton

**意图**：进程内唯一实例。**优先 Hilt `@Singleton`**，避免手写双重检查锁除非必要。

### Java — 推荐 DI

```java
@Module
@InstallIn(SingletonComponent.class)
public class NetworkModule {
    @Provides
    @Singleton
    public static OkHttpClient provideOkHttpClient() {
        return new OkHttpClient.Builder().build();
    }
}
```

### Kotlin — Hilt

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient = OkHttpClient.Builder().build()
}

object AppGraph {
    val analytics: Analytics by lazy { AnalyticsImpl() }
}
```

---

## 选用建议

| 需求 | 推荐模式 |
|------|----------|
| 一屏数据 + 业务逻辑 | MVVM + UDF UI State |
| 多数据源（API + Room） | Repository + Mapper |
| 多 ViewModel 共用规则 | Use Case |
| 列表性能 | Adapter + DiffUtil / `ListAdapter` |
| 条件分支爆炸 | Strategy |
| 测试与替换实现 | 接口 + DI（Hilt），少用静态 Singleton |

## 相关文档

- [编码约束核心](android-coding-standard.md)
- [命名表](reference.md)
- [文档地图](README.md)