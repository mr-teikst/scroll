-- +goose Up
-- +goose StatementBegin
create table l2_sent_msg
(
    id               BIGSERIAL PRIMARY KEY,
    msg_hash         VARCHAR NOT NULL,
    height           BIGINT NOT NULL,
    nonce            BIGINT NOT NULL,
    finalized_height BIGINT DEFAULT NULL,
    layer1_hash      VARCHAR NOT NULL DEFAULT '',
    batch_index      BIGINT DEFAULT NULL,
    msg_proof        TEXT DEFAULT '',
    msg_data         VARCHAR DEFAULT '',
    is_deleted       BOOLEAN NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at       TIMESTAMP(0) DEFAULT NULL
);

comment 
on column l2_sent_msg.is_deleted is 'NotDeleted, Deleted';

create unique index l2_sent_msg_hash_uindex
on l2_sent_msg (msg_hash);

CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_timestamp BEFORE UPDATE
ON l2_sent_msg FOR EACH ROW EXECUTE PROCEDURE
update_timestamp();

CREATE OR REPLACE FUNCTION delete_at_trigger()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_deleted AND OLD.is_deleted != NEW.is_deleted THEN
        UPDATE l2_sent_msg SET delete_at = NOW() WHERE id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_at_trigger
AFTER UPDATE ON l2_sent_msg
FOR EACH ROW
EXECUTE FUNCTION delete_at_trigger();


-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
drop table if exists l2_sent_msg;
-- +goose StatementEnd