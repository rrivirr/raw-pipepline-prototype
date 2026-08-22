"""partition_meter_table

Revision ID: 91336faf259f
Revises: 0fe1b9298b97
Create Date: 2026-08-21 19:21:03.906556

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '91336faf259f'
down_revision: Union[str, Sequence[str], None] = '0fe1b9298b97'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
	# Create hypertable manually or via extension
    connection = op.get_bind()
    connection.execute(sa.text("""
        SELECT create_hypertable('meter', 'measured_at',
                                 number_partitions => 8);
    """))
    connection.commit()
    pass
		

def downgrade() -> None:
    """Downgrade schema."""
    pass