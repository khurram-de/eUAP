select
	order_id as order_id,
	review_id as review_id,
	review_score as review_score,
	review_comment_title as review_comment_title,
	review_comment_message as review_comment_message,
	review_creation_date as review_creation_date,
	review_answer_timestamp as review_answer_timestamp,
    _business_date,
    _ingested_at,
    _source_file
from {{ source('ecom_raw_staging', 'reviews') }}