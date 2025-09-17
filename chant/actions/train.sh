export PYTHONPATH=${PYTHONPATH}:/ru-gpts/
CUDA_VISIBLE_DEVICES=0 python ru-gpts/pretrain_transformers.py \
    --output_dir=models/armysmall \
    --model_type=gpt2 \
    --model_name_or_path=sberbank-ai/rugpt3small_based_on_gpt2 \
    --do_train \
    --train_data_file=train2.txt \
    --do_eval \
    --eval_data_file=valid2.txt \
    --per_gpu_train_batch_size 1 \
    --gradient_accumulation_steps 1 \
    --num_train_epochs 5 \
    --block_size 2048 \
    --overwrite_output_dir