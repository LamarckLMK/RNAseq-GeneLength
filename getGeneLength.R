# 安装必要的包
install.packages("biomaRt")
BiocManager::install("biomaRt")

# 加载 biomaRt
library(biomaRt)

# 1. 读取表达矩阵文件
file_path <- "C:/Users/Lamarck/Desktop/mycounts.csv"
exprData <- read.csv(file_path, header = TRUE)

# 检查数据结构
head(exprData)

# 如果基因ID有版本号（如 ENSG000001.1），需要去掉版本号
exprData[, 1] <- gsub("\\..*", "", exprData[, 1])

# 删除表达量全为0的行
# 假设表达量列从第二列开始（第一列是基因 ID）
exprData <- exprData[rowSums(exprData[, -1] != 0) > 0, ]

# 检查数据结构
head(exprData)

# 2. 连接到 Ensembl 数据库
ensembl <- useMart("ensembl", 
                   dataset = "hsapiens_gene_ensembl", 
                   host = "https://asia.ensembl.org")

# 3. 查询基因长度
gene_lengths <- getBM(
  attributes = c("ensembl_gene_id", "start_position", "end_position"),
  filters = "ensembl_gene_id",
  values = exprData[, 1],  # 基因 ID 列
  mart = ensembl
)

# 计算基因长度
gene_lengths$length <- gene_lengths$end_position - gene_lengths$start_position + 1

# 检查查询结果
head(gene_lengths)

# 4. 将基因长度合并到表达矩阵
exprData$Length <- gene_lengths[match(exprData[, 1], gene_lengths$ensembl_gene_id), "length"]

# 检查合并后的数据
head(exprData)

# 5. 保存结果到新文件
output_file <- "C:/Users/Lamarck/Desktop/mycounts_lengths.csv"
write.csv(exprData, file = output_file, row.names = FALSE)
